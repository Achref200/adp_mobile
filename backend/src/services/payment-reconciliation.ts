import { db, type DbClient } from '../config/database.js';
import { AppError } from '../types/api.js';
import { HelloAssoClient } from './helloasso-client.js';

type WebhookPayload = {
  data?: { checkoutIntentId?: string | number };
  checkoutIntentId?: string | number;
  metadata?: { donationId?: string; membershipId?: string };
};

/**
 * Payment state changes happen here, never from a browser redirect. The provider
 * is queried again before a donation or membership is marked as paid.
 */
export class PaymentReconciliationService {
  constructor(private readonly helloAsso = new HelloAssoClient()) {}

  async processWebhook(eventId: string): Promise<void> {
    const event = await db.query<{ payload: WebhookPayload }>(
      'SELECT payload FROM helloasso_webhook_events WHERE event_id = $1 AND processed_at IS NULL',
      [eventId],
    );
    const payload = event.rows[0]?.payload;
    if (!payload) return;

    const checkoutIntentId = this.checkoutIntentId(payload);
    if (!checkoutIntentId) {
      await this.recordEventOutcome(eventId, 'No checkout intent in this notification.');
      return;
    }

    try {
      const result = await this.reconcileCheckout(checkoutIntentId, payload.metadata);
      await this.recordEventOutcome(eventId, result === 'pending' ? 'Awaiting provider confirmation.' : undefined, result === 'confirmed');
    } catch (error) {
      await this.recordEventOutcome(eventId, error instanceof Error ? error.message : 'Unable to reconcile payment.', false);
    }
  }

  async reconcileCheckout(checkoutIntentId: string, metadata?: WebhookPayload['metadata']): Promise<'confirmed' | 'pending'> {
    const checkout = await this.helloAsso.getCheckoutIntent(checkoutIntentId);
    if (!checkout.order) return 'pending';

    const donationId = metadata?.donationId ?? checkout.metadata?.donationId;
    const membershipId = metadata?.membershipId ?? checkout.metadata?.membershipId;
    const orderId = checkout.order.id == null ? null : String(checkout.order.id);
    const client = await db.connect();
    try {
      await client.query('BEGIN');
      if (donationId) {
        const donation = await client.query<{ userId: string | null }>(
          `UPDATE donations
           SET status = 'confirmed', helloasso_checkout_intent_id = $2, helloasso_order_id = COALESCE($3, helloasso_order_id)
           WHERE id = $1 AND status = 'pending'
           RETURNING user_id AS "userId"`,
          [donationId, checkoutIntentId, orderId],
        );
        if (donation.rows[0]?.userId) {
          await this.notify(client, donation.rows[0].userId, 'donation_confirmed', 'Thank you for your support', 'Your donation has been confirmed by HelloAsso.');
        }
      }
      if (membershipId) {
        const membership = await client.query<{ userId: string }>(
          `UPDATE memberships
           SET status = 'paymentConfirmed', paid_at = NOW(), helloasso_checkout_intent_id = $2, helloasso_order_id = COALESCE($3, helloasso_order_id)
           WHERE id = $1 AND status IN ('submitted', 'paymentConfirmed')
           RETURNING user_id AS "userId"`,
          [membershipId, checkoutIntentId, orderId],
        );
        if (membership.rows[0]?.userId) {
          await this.notify(client, membership.rows[0].userId, 'membership_payment_confirmed', 'Membership payment confirmed', 'Your request is now waiting for the ADP review.');
        }
      }
      await client.query('COMMIT');
      return 'confirmed';
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async reconcilePendingWebhooks(limit = 20): Promise<number> {
    const { rows } = await db.query<{ eventId: string }>(
      `SELECT event_id AS "eventId" FROM helloasso_webhook_events
       WHERE processed_at IS NULL
       ORDER BY received_at ASC
       LIMIT $1`,
      [limit],
    );
    for (const row of rows) await this.processWebhook(row.eventId);
    return rows.length;
  }

  private checkoutIntentId(payload: WebhookPayload): string | undefined {
    const value = payload.data?.checkoutIntentId ?? payload.checkoutIntentId;
    return value == null ? undefined : String(value);
  }

  private async recordEventOutcome(eventId: string, processingError?: string, complete = true): Promise<void> {
    await db.query(
      'UPDATE helloasso_webhook_events SET processed_at = CASE WHEN $3 THEN NOW() ELSE NULL END, processing_error = $2 WHERE event_id = $1',
      [eventId, processingError ?? null, complete],
    );
  }

  private async notify(client: { query: (sql: string, params?: any[]) => Promise<any> }, userId: string, type: string, title: string, body: string): Promise<void> {
    await client.query(
      'INSERT INTO notifications (user_id, type, title, body) VALUES ($1, $2, $3, $4)',
      [userId, type, title, body],
    );
  }
}

export function assertCheckoutOwnership(recordUserId: string | null, requestUserId: string): void {
  if (recordUserId !== requestUserId) throw new AppError(404, 'checkout_not_found', 'Checkout not found.');
}

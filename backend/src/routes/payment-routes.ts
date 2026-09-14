import { createHash, createHmac, randomUUID, timingSafeEqual } from 'node:crypto';
import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { db } from '../config/database.js';
import { env } from '../config/env.js';
import { requireAuth } from '../middleware/auth.js';
import { MemberRepository } from '../repositories/member-repository.js';
import { UserRepository } from '../repositories/user-repository.js';
import { HelloAssoClient } from '../services/helloasso-client.js';
import { PaymentReconciliationService } from '../services/payment-reconciliation.js';
import { TokenService } from '../services/token-service.js';
import { AppError } from '../types/api.js';

const donationSchema = z.object({ amountCents: z.number().int().positive().max(100000000), frequency: z.enum(['oneOff', 'monthly']), anonymous: z.boolean().default(false), projectId: z.string().uuid().optional(), donorEmail: z.string().email().optional() });
const membershipSchema = z.object({ membershipId: z.string().uuid() });

export async function paymentRoutes(app: FastifyInstance): Promise<void> {
  const helloAsso = new HelloAssoClient();
  const reconciliation = new PaymentReconciliationService(helloAsso);
  const members = new MemberRepository();
  const users = new UserRepository();
  const tokens = new TokenService();

  app.post('/checkout/donations', async (request, reply) => {
    const input = donationSchema.parse(request.body);
    const userId = optionalUserId(request, tokens);
    const donationId = randomUUID();
    await db.query(
      "INSERT INTO donations (id, user_id, project_id, donor_email, anonymous, amount_cents, frequency, status) VALUES ($1,$2,$3,$4,$5,$6,$7,'pending')",
      [donationId, userId, input.projectId ?? null, input.donorEmail ?? null, input.anonymous, input.amountCents, input.frequency],
    );
    if (input.frequency === 'monthly') {
      if (!env.HELLOASSO_DONATION_FORM_URL) throw new AppError(503, 'recurring_payments_unavailable', 'The HelloAsso recurring donation form is not configured.');
      return reply.code(202).send({ donationId, status: 'pending', checkoutUrl: env.HELLOASSO_DONATION_FORM_URL, paymentProvider: 'helloassoHostedForm' });
    }
    const payer = userId ? await users.findById(userId) : undefined;
    const checkout = await helloAsso.createCheckout({
      amountCents: input.amountCents,
      itemName: input.projectId ? 'ADP project donation' : 'ADP donation',
      containsDonation: true,
      payer: payer ? { firstName: payer.firstName, lastName: payer.lastName, email: payer.email } : undefined,
      metadata: { donationId, userId: userId ?? '', projectId: input.projectId ?? '' },
    });
    await db.query('UPDATE donations SET helloasso_checkout_intent_id = $2 WHERE id = $1', [donationId, checkout.id]);
    return reply.code(202).send({ donationId, checkoutIntentId: checkout.id, status: 'pending', checkoutUrl: checkout.redirectUrl, paymentProvider: 'helloassoCheckout' });
  });

  app.post('/checkout/memberships', { preHandler: requireAuth }, async (request, reply) => {
    const { membershipId } = membershipSchema.parse(request.body);
    const membership = await members.current(request.userId);
    if (!membership || membership.id !== membershipId) throw new AppError(404, 'membership_not_found', 'Membership request not found.');
    const user = await users.findById(request.userId);
    if (!user) throw new AppError(404, 'user_not_found', 'User not found.');
    const checkout = await helloAsso.createCheckout({
      amountCents: membership.amountCents,
      itemName: `ADP membership — ${membership.plan}`,
      containsDonation: false,
      payer: { firstName: user.firstName, lastName: user.lastName, email: user.email },
      metadata: { membershipId, userId: request.userId },
    });
    await db.query('UPDATE memberships SET helloasso_checkout_intent_id = $2 WHERE id = $1', [membershipId, checkout.id]);
    return reply.code(202).send({ membershipId, checkoutIntentId: checkout.id, status: 'pending', checkoutUrl: checkout.redirectUrl, paymentProvider: 'helloassoCheckout' });
  });

  app.get('/checkout/status/:checkoutIntentId', { preHandler: requireAuth }, async (request) => {
    const { checkoutIntentId } = z.object({ checkoutIntentId: z.string().min(1).max(128) }).parse(request.params);
    const ownership = await db.query<{ userId: string | null }>(
      `SELECT user_id AS "userId" FROM donations WHERE helloasso_checkout_intent_id = $1
       UNION ALL SELECT user_id AS "userId" FROM memberships WHERE helloasso_checkout_intent_id = $1 LIMIT 1`,
      [checkoutIntentId],
    );
    if (ownership.rows[0]?.userId !== request.userId) throw new AppError(404, 'checkout_not_found', 'Checkout not found.');
    const verification = await reconciliation.reconcileCheckout(checkoutIntentId);
    const state = await db.query<{ kind: 'donation' | 'membership'; status: string }>(
      `SELECT 'donation'::text AS kind, status::text FROM donations WHERE helloasso_checkout_intent_id = $1
       UNION ALL SELECT 'membership'::text AS kind, status::text FROM memberships WHERE helloasso_checkout_intent_id = $1 LIMIT 1`,
      [checkoutIntentId],
    );
    return { verification, checkout: state.rows[0] ?? null };
  });

  app.post('/helloasso/webhook', { config: { rawBody: true } }, async (request, reply) => {
    const signature = request.headers['x-ha-signature'];
    const raw = request.rawBody;
    if (!env.HELLOASSO_WEBHOOK_SECRET || typeof signature !== 'string' || typeof raw !== 'string') throw new AppError(401, 'invalid_webhook', 'Webhook signature is required.');
    const expected = createHmac('sha256', env.HELLOASSO_WEBHOOK_SECRET).update(raw).digest('hex');
    if (expected.length !== signature.length || !timingSafeEqual(Buffer.from(expected), Buffer.from(signature))) throw new AppError(401, 'invalid_webhook', 'Webhook signature is invalid.');
    const body = request.body as { eventType?: string };
    const eventId = createHash('sha256').update(raw).digest('hex');
    await db.query(
      'INSERT INTO helloasso_webhook_events (event_id, event_type, payload) VALUES ($1,$2,$3) ON CONFLICT (event_id) DO NOTHING',
      [eventId, body.eventType ?? 'unknown', request.body],
    );
    await reconciliation.processWebhook(eventId);
    return reply.code(202).send({ accepted: true });
  });
}

function optionalUserId(request: FastifyRequest, tokens: TokenService): string | null {
  const header = request.headers.authorization;
  return header?.startsWith('Bearer ') ? tokens.verifyAccessToken(header.slice(7)) : null;
}

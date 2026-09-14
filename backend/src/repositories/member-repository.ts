import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
import type { MembershipStatus } from '../types/api.js';

export type MembershipRecord = { id: string; plan: string; amountCents: number; status: MembershipStatus; expiresAt: string | null };
export class MemberRepository {
  async current(userId: string): Promise<MembershipRecord | null> {
    const { rows } = await db.query<MembershipRecord>('SELECT id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt" FROM memberships WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1', [userId]);
    return rows[0] ?? null;
  }
  async submit(userId: string, input: { plan: string; amountCents: number; djerbaConnection: string; motivation?: string }): Promise<MembershipRecord> {
    const { rows } = await db.query<MembershipRecord>('INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at) VALUES ($1,$2,$3,$4,$5,$6,\'submitted\',NOW()) RETURNING id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt"', [randomUUID(), userId, input.plan, input.amountCents, input.djerbaConnection, input.motivation ?? null]);
    return rows[0];
  }
}

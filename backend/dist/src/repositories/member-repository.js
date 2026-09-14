import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
export class MemberRepository {
    async current(userId) {
        const { rows } = await db.query('SELECT id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt" FROM memberships WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1', [userId]);
        return rows[0] ?? null;
    }
    async submit(userId, input) {
        const { rows } = await db.query('INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at) VALUES ($1,$2,$3,$4,$5,$6,\'submitted\',NOW()) RETURNING id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt"', [randomUUID(), userId, input.plan, input.amountCents, input.djerbaConnection, input.motivation ?? null]);
        return rows[0];
    }
}

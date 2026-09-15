import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
export class MemberRepository {
    /** Lazily expires any active membership whose validity date has passed. */
    async expireIfDue(userId) {
        await db.query("UPDATE memberships SET status = 'expired' WHERE user_id = $1 AND status = 'active' AND expires_at IS NOT NULL AND expires_at < CURRENT_DATE", [userId]);
    }
    async current(userId) {
        await this.expireIfDue(userId);
        const { rows } = await db.query('SELECT id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt" FROM memberships WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1', [userId]);
        return rows[0] ?? null;
    }
    async byId(id) {
        const { rows } = await db.query('SELECT id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt" FROM memberships WHERE id = $1', [id]);
        return rows[0] ?? null;
    }
    async submit(userId, input) {
        const { rows } = await db.query('INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, motivation, status, submitted_at) VALUES ($1,$2,$3,$4,$5,$6,\'submitted\',NOW()) RETURNING id, plan, amount_cents AS "amountCents", status, expires_at AS "expiresAt"', [randomUUID(), userId, input.plan, input.amountCents, input.djerbaConnection, input.motivation ?? null]);
        return rows[0];
    }
}

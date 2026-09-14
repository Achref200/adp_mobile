import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
export class PrivacyRepository {
    async recordConsent(userId, input) {
        const { rows } = await db.query('INSERT INTO consents (id, user_id, purpose, granted) VALUES ($1, $2, $3, $4) RETURNING id, purpose, granted, recorded_at AS "recordedAt"', [randomUUID(), userId, input.purpose, input.granted]);
        return rows[0];
    }
    async exportData(userId) {
        const [user, memberships, donations, networking, consents, notifications] = await Promise.all([
            db.query('SELECT id, email, first_name AS "firstName", last_name AS "lastName", country, directory_visible AS "directoryVisible", created_at AS "createdAt" FROM users WHERE id = $1', [userId]),
            db.query('SELECT id, plan, amount_cents AS "amountCents", status, submitted_at AS "submittedAt", paid_at AS "paidAt", expires_at AS "expiresAt", created_at AS "createdAt" FROM memberships WHERE user_id = $1 ORDER BY created_at DESC', [userId]),
            db.query('SELECT id, project_id AS "projectId", amount_cents AS "amountCents", frequency, anonymous, status, created_at AS "createdAt" FROM donations WHERE user_id = $1 ORDER BY created_at DESC', [userId]),
            db.query('SELECT city, sector, skills, visibility, updated_at AS "updatedAt" FROM networking_profiles WHERE user_id = $1', [userId]),
            db.query('SELECT purpose, granted, recorded_at AS "recordedAt" FROM consents WHERE user_id = $1 ORDER BY recorded_at DESC', [userId]),
            db.query('SELECT id, type, title, body, read_at AS "readAt", created_at AS "createdAt" FROM notifications WHERE user_id = $1 ORDER BY created_at DESC', [userId]),
        ]);
        return {
            generatedAt: new Date().toISOString(),
            user: user.rows[0] ?? null,
            memberships: memberships.rows,
            donations: donations.rows,
            networkingProfile: networking.rows[0] ?? null,
            consents: consents.rows,
            notifications: notifications.rows,
        };
    }
    async requestErasure(userId) {
        const { rows } = await db.query(`INSERT INTO data_subject_requests (id, user_id, request_type, status)
       VALUES ($1, $2, 'erasure', 'requested')
       RETURNING id, status, created_at AS "createdAt"`, [randomUUID(), userId]);
        return rows[0];
    }
}

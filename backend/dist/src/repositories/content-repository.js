import { db } from '../config/database.js';
export class ContentRepository {
    async projects() {
        const { rows } = await db.query('SELECT id, title, category, summary, COALESCE(progress, 0) AS progress, COALESCE(target_cents, 0) AS "targetCents", raised_cents AS "raisedCents", location FROM projects WHERE published = TRUE ORDER BY featured DESC, created_at DESC');
        return rows.map((row) => ({ ...row, progress: Number(row.progress) }));
    }
    async rows(table) {
        const sql = table === 'news'
            ? 'SELECT id, title, excerpt, body, category, cover_image_url AS "coverImageUrl", created_at AS "publishedAt" FROM news WHERE published = TRUE ORDER BY created_at DESC'
            : 'SELECT id, title, summary, location, starts_at AS "startsAt", ends_at AS "endsAt", created_at AS "publishedAt" FROM events WHERE published = TRUE ORDER BY starts_at ASC NULLS LAST';
        const { rows } = await db.query(sql);
        return rows;
    }
}

import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
const columns = 'id, first_name AS "firstName", last_name AS "lastName", email, country, directory_visible AS "directoryVisible"';
export class UserRepository {
    async findByEmail(email) {
        const { rows } = await db.query(`SELECT ${columns}, password_hash AS "passwordHash" FROM users WHERE email = $1 AND deleted_at IS NULL`, [email.toLowerCase()]);
        return rows[0] ?? null;
    }
    async findById(id) {
        const { rows } = await db.query(`SELECT ${columns} FROM users WHERE id = $1 AND deleted_at IS NULL`, [id]);
        return rows[0] ?? null;
    }
    async create(input) {
        const id = randomUUID();
        const { rows } = await db.query(`INSERT INTO users (id, first_name, last_name, email, country, password_hash) VALUES ($1,$2,$3,$4,$5,$6) RETURNING ${columns}`, [id, input.firstName, input.lastName, input.email.toLowerCase(), input.country, input.passwordHash]);
        return rows[0];
    }
}

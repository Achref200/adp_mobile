import { randomUUID } from 'node:crypto';
import { db } from '../config/database.js';
import type { ApiUser } from '../types/api.js';

const columns = 'id, first_name AS "firstName", last_name AS "lastName", email, country, directory_visible AS "directoryVisible"';
export class UserRepository {
  async findByEmail(email: string): Promise<(ApiUser & { passwordHash: string }) | null> {
    const { rows } = await db.query(`SELECT ${columns}, password_hash AS "passwordHash" FROM users WHERE email = $1 AND deleted_at IS NULL`, [email.toLowerCase()]);
    return rows[0] ?? null;
  }
  async findByGoogleSub(googleSub: string): Promise<(ApiUser & { passwordHash: string }) | null> {
    const { rows } = await db.query(`SELECT ${columns}, password_hash AS "passwordHash" FROM users WHERE google_sub = $1 AND deleted_at IS NULL`, [googleSub]);
    return rows[0] ?? null;
  }
  async linkGoogle(id: string, googleSub: string): Promise<void> {
    await db.query('UPDATE users SET google_sub = $2 WHERE id = $1 AND google_sub IS NULL', [id, googleSub]);
  }
  async findById(id: string): Promise<ApiUser | null> {
    const { rows } = await db.query(`SELECT ${columns} FROM users WHERE id = $1 AND deleted_at IS NULL`, [id]);
    return rows[0] ?? null;
  }
  async create(input: Omit<ApiUser, 'id' | 'directoryVisible'> & { passwordHash: string; googleSub?: string }): Promise<ApiUser> {
    const id = randomUUID();
    const { rows } = await db.query(`INSERT INTO users (id, first_name, last_name, email, country, password_hash, google_sub) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING ${columns}`, [id, input.firstName, input.lastName, input.email.toLowerCase(), input.country, input.passwordHash, input.googleSub ?? null]);
    return rows[0];
  }
}

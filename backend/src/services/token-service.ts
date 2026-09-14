import { createHash, randomBytes, randomUUID } from 'node:crypto';
import jwt from 'jsonwebtoken';
import { db } from '../config/database.js';
import { env } from '../config/env.js';

export class TokenService {
  issueAccessToken(userId: string): string { return jwt.sign({ sub: userId, typ: 'access' }, env.JWT_ACCESS_SECRET, { expiresIn: '15m' }); }
  async issueRefreshToken(userId: string): Promise<string> {
    const raw = randomBytes(48).toString('base64url');
    await db.query('INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at) VALUES ($1,$2,$3, NOW() + INTERVAL \'30 days\')', [randomUUID(), userId, this.hash(raw)]);
    return raw;
  }
  async rotate(raw: string): Promise<{ accessToken: string; refreshToken: string } | null> {
    const client = await db.connect();
    try {
      await client.query('BEGIN');
      const { rows } = await client.query('SELECT id, user_id FROM refresh_tokens WHERE token_hash = $1 AND revoked_at IS NULL AND expires_at > NOW() FOR UPDATE', [this.hash(raw)]);
      if (!rows[0]) { await client.query('ROLLBACK'); return null; }
      await client.query('UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = $1', [rows[0].id]);
      const next = randomBytes(48).toString('base64url');
      await client.query('INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at) VALUES ($1,$2,$3, NOW() + INTERVAL \'30 days\')', [randomUUID(), rows[0].user_id, this.hash(next)]);
      await client.query('COMMIT');
      return { accessToken: this.issueAccessToken(rows[0].user_id), refreshToken: next };
    } catch (error) { await client.query('ROLLBACK'); throw error; } finally { client.release(); }
  }
  verifyAccessToken(token: string): string | null { try { const decoded = jwt.verify(token, env.JWT_ACCESS_SECRET); return typeof decoded === 'object' && typeof decoded.sub === 'string' ? decoded.sub : null; } catch { return null; } }
  private hash(token: string): string { return createHash('sha256').update(token).digest('hex'); }
}

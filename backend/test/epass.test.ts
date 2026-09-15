import assert from 'node:assert/strict';
import test from 'node:test';
import { createHmac, randomUUID } from 'node:crypto';
import { buildApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { db } from '../src/config/database.js';
import { TokenService } from '../src/services/token-service.js';

// The test provisions its own user and active membership so it does not
// depend on seed data, and works identically on PostgreSQL and SQLite.
test('e-pass contract: issue, verify, and reject tampered payloads', async () => {
  const userId = `test_epass_${randomUUID()}`;
  const membershipId = `test_mem_${randomUUID()}`;
  const nextYear = new Date();
  nextYear.setFullYear(nextYear.getFullYear() + 1);
  const validUntil = nextYear.toISOString().slice(0, 10);

  await db.query(
    'INSERT INTO users (id, email, first_name, last_name, country, password_hash) VALUES ($1,$2,$3,$4,$5,$6)',
    [userId, `${userId}@example.test`, 'Test', 'EPass', 'France', 'not-a-real-password-hash'],
  );
  await db.query(
    "INSERT INTO memberships (id, user_id, plan, amount_cents, djerba_connection, status, submitted_at, paid_at, expires_at) VALUES ($1,$2,$3,$4,$5,'active',NOW(),NOW(),$6)",
    [membershipId, userId, 'individual', 5000, 'Test connection', validUntil],
  );

  const app = buildApp();
  const tokens = new TokenService();
  const authHeaders = { authorization: `Bearer ${tokens.issueAccessToken(userId)}` };

  try {
    // Issuance requires an active membership and returns the signed QR payload.
    const issue = await app.inject({ method: 'GET', url: '/v1/me/e-pass', headers: authHeaders });
    assert.equal(issue.statusCode, 200);
    const pass = issue.json();
    assert.equal(pass.memberId, membershipId);
    assert.equal(pass.status, 'active');
    assert.equal(pass.validUntil, validUntil);

    // Payload shape: ADP1.<membershipId>.<userId>.<validUntil>.<hmac(base64url)>
    const parts = String(pass.qrPayload).split('.');
    assert.equal(parts.length, 5);
    assert.equal(parts[0], 'ADP1');
    assert.equal(parts[1], membershipId);
    assert.equal(parts[2], userId);
    const expectedSignature = createHmac('sha256', env.EPASS_SIGNING_SECRET)
      .update(`${parts[1]}.${parts[2]}.${parts[3]}`)
      .digest('base64url');
    assert.equal(parts[4], expectedSignature);

    // Verifying a genuine payload succeeds while the membership is active.
    const verify = await app.inject({ method: 'GET', url: `/v1/e-pass/verify/${pass.qrPayload}`, headers: authHeaders });
    assert.equal(verify.statusCode, 200);
    assert.deepEqual(verify.json(), { valid: true, status: 'active', validUntil });

    // A tampered signature is rejected with invalid_pass.
    const tampered = [...parts.slice(0, 4), 'A'.repeat(43)].join('.');
    const reject = await app.inject({ method: 'GET', url: `/v1/e-pass/verify/${tampered}`, headers: authHeaders });
    assert.equal(reject.statusCode, 400);
    assert.equal(reject.json().error.code, 'invalid_pass');

    // Malformed payloads are rejected before any signature check.
    const malformed = await app.inject({ method: 'GET', url: '/v1/e-pass/verify/not-a-pass', headers: authHeaders });
    assert.equal(malformed.statusCode, 400);
    assert.equal(malformed.json().error.code, 'invalid_pass');

    // Both endpoints require authentication.
    const anonymous = await app.inject({ method: 'GET', url: '/v1/me/e-pass' });
    assert.equal(anonymous.statusCode, 401);
  } finally {
    await db.query('DELETE FROM memberships WHERE user_id = $1', [userId]);
    await db.query('DELETE FROM users WHERE id = $1', [userId]);
  }
});

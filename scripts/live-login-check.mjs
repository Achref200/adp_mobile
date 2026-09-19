// Live login-workflow probe for the deployed ADP backend.
// Usage: node scripts/live-login-check.mjs [baseUrl]
const base = process.argv[2] || 'https://adp-mobile-chi.vercel.app';
const email = `clinetest${Date.now()}@example.com`;
const password = 'Password123456!';

const post = async (path, body, token) => {
  const res = await fetch(base + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let json;
  try { json = JSON.parse(text); } catch { json = { raw: text.slice(0, 300) }; }
  return { status: res.status, json };
};
const get = async (path, token) => {
  const res = await fetch(base + path, { headers: { Authorization: `Bearer ${token}` } });
  return { status: res.status, json: await res.json().catch(() => null) };
};

const log = (label, r) => console.log(`${r.status < 300 ? 'PASS' : 'FAIL'}  ${label}  ->  ${r.status} ${JSON.stringify(r.json).slice(0, 220)}`);

const health = await get('/health', '');
console.log('HEALTH', JSON.stringify(health.json));

const reg = await post('/v1/auth/register', { firstName: 'Cline', lastName: 'Tester', email, country: 'Tunisia', password });
log('register', reg);
const login = await post('/v1/auth/login', { email, password });
log('login (same instance)', login);
const me = await get('/v1/me', login.json?.accessToken);
log('/v1/me with access token', me);
const ref = await post('/v1/auth/refresh', { refreshToken: login.json?.refreshToken });
log('refresh (rotate)', ref);

// Re-login with the SAME credentials — the reported production failure mode.
const login2 = await post('/v1/auth/login', { email, password });
log('login again (same credentials)', login2);
if (login2.status >= 300) {
  console.log('\n>>> REPRODUCED: account created minutes ago can no longer log in (ephemeral DB).');
}
if (ref.status >= 300) {
  console.log('\n>>> REPRODUCED: refresh rotation fails (SQLite transaction translation).');
}

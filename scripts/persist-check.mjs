// Persistence probe: run 1 = `node scripts/persist-check.mjs register`, run 2 (after server restart) = `node scripts/persist-check.mjs login`
// Fixed credentials across runs; proves accounts survive a backend restart.
const base = 'http://localhost:8080';
const email = 'persist.check@example.com';
const password = 'PersistCheck123!';
const mode = process.argv[2] || 'register';

const post = async (path, body) => {
  const res = await fetch(base + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await res.json().catch(() => ({}));
  return { status: res.status, json };
};

if (mode === 'register') {
  const reg = await post('/v1/auth/register', { firstName: 'Persist', lastName: 'Check', email, country: 'Tunisia', password });
  console.log(mode, reg.status, reg.json?.user?.id ?? JSON.stringify(reg.json).slice(0, 160));
} else {
  const login = await post('/v1/auth/login', { email, password });
  console.log('login-after-restart', login.status, login.status === 200 ? 'OK — account survived restart' : JSON.stringify(login.json).slice(0, 160));
  if (login.status === 200) {
    const ref = await post('/v1/auth/refresh', { refreshToken: login.json.refreshToken });
    console.log('refresh-after-restart', ref.status, ref.status === 200 ? 'OK — refresh token survived restart' : JSON.stringify(ref.json).slice(0, 160));
  }
}

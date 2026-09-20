# Google Sign-In — activation guide

The entire flow is implemented and deployed. The **only** missing piece is the
Google OAuth client ID, which only a Google-account holder can create.

## Create the client ID (5 minutes, one person, one login)

1. Open <https://console.cloud.google.com/apis/credentials> and sign in with
   the association's Google account (create one if needed).
2. If prompted, create a project (e.g. `adp-mobile`) — the free tier is enough.
3. **APIs & Services → OAuth consent screen**:
   - User type: **External**, fill the app name (`ADP — Association Djerba Project`),
     support email, and add your email as a test user while in *Testing* mode
     (or publish the app so anyone can sign in).
4. **Credentials → Create credentials → OAuth client ID**:
   - Application type: **Web application**
   - Authorized JavaScript origins: `https://adp-mobile-chi.vercel.app`
     (and `http://localhost:8080` for local testing)
   - No redirect URIs needed (the flow uses Google Identity Services token mode).
5. Copy the client ID (format `1234567890-abc123.apps.googleusercontent.com`).

## Activate (one command)

From the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\activate-google-signin.ps1 -ClientId "PASTE-ID-HERE.apps.googleusercontent.com"
```

The script adds the ID to Vercel (production + preview), to `backend/.env`,
rebuilds the Flutter web bundle with it baked in, and pushes — Vercel
redeploys automatically. Wait ~4 minutes, then test the button.

## What happens under the hood (for reference)

```
[Button "Continuer avec Google"]
  → GoogleSignIn.initialize(clientId: --dart-define GOOGLE_CLIENT_ID)
  → google.authenticate() → idToken
  → POST /v1/auth/google { idToken }
  → backend verifies signature (Google JWKS, RS256), issuer, expiry,
    and audience (= the same client ID)
  → account linked by googleSub, or linked by email, or provisioned
  → ADP access + refresh tokens issued and stored
```

Local dev: put `GOOGLE_CLIENT_ID=...` in `backend/.env` and run
`flutter run -d chrome --dart-define=GOOGLE_CLIENT_ID=...`.

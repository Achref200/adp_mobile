# ADP backend and HelloAsso boundary

```
Flutter app -> ADP API -> PostgreSQL/MySQL
                  |         ^
                  v         |
              HelloAsso ----- webhook (signature verified, idempotent)
                  |
            hosted checkout in system browser / secure custom tab
```

The Flutter app only asks the ADP API for a vetted `checkoutUrl`; it opens that URL externally or in a platform secure browser. It never sends or stores card details, HelloAsso OAuth credentials, client secrets or webhook secrets.

## Proposed API surface

| Method | Path | Purpose |
|---|---|---|
| POST | `/v1/auth/login` | Authenticate and issue short-lived access / rotating refresh tokens |
| GET | `/v1/me` | Current user and consent flags |
| GET/POST | `/v1/memberships` | Read status / submit dossier (manual-review queue) |
| POST | `/v1/checkout/donations` | Validate intent and return hosted HelloAsso URL |
| POST | `/v1/checkout/memberships` | Create membership payment flow |
| GET | `/v1/projects`, `/v1/news`, `/v1/events` | Public cacheable content |
| GET | `/v1/me/e-pass` | Signed, short-lived validation token and membership status |
| POST | `/v1/devices` | Register push token and preferences |
| POST | `/v1/helloasso/webhook` | Server-only HelloAsso endpoint |

## Payment lifecycle

1. App sends amount, frequency, optional project ID and user email to ADP API.
2. Backend validates values, records a pending intent, and builds/obtains the HelloAsso hosted flow.
3. App opens the returned URL; payment data is entered only at HelloAsso.
4. HelloAsso redirects to `adp://payment-return/...` (or verified Universal/App Link). This is only UX feedback, not confirmation.
5. HelloAsso webhook reaches ADP backend. Verify its signature, persist raw event ID, and atomically update donation/membership.
6. Backend sends FCM/APNs notification and the app refreshes its status.

Reject duplicate webhook event IDs. Reconcile delayed webhooks through a scheduled server job. The signed e-Pass payload must be opaque, expire quickly, and be verified by a backend/authorized scanner; do not place raw member data in the QR code.

## RGPD / operations

Use explicit opt-in for directory visibility and communications; keep a timestamped consent record. Provide export/delete workflows, retention schedules, audit logs for bureau actions, encryption at rest, TLS, least-privilege roles, backups, and a public privacy notice. Cache only previously viewed projects/news and a membership/e-Pass snapshot locally; encrypt session tokens in Keychain/Keystore. Membership drafts require an encrypted local store and a retry queue once authentication is implemented.

For LWS hosting, validate PHP/runtime version, HTTPS, database, logs, cron jobs and ability to expose `https://api.djerbaproject.fr/v1/helloasso/webhook`. A small PHP/Laravel/Symfony API plus MySQL/MariaDB is a viable deployment; the mobile contract remains the same.

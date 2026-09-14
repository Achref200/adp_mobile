# ADP API

Node 24 / TypeScript / Fastify / PostgreSQL API for the ADP Flutter client. It is deliberately the only system that may receive HelloAsso OAuth or webhook secrets.

## Local setup

1. Provision PostgreSQL 16+ and create database `adp`.
2. Copy `.env.example` to `.env` and supply unique development secrets.
3. Run `npm install`, then apply `database/migrations/001_initial.sql` with your database migration runner.
4. Run `npm run dev`; `GET /health` should return `{ "ok": true }`.

The API does not include an admin console yet. Projects, news, and events are published by applying SQL changes to PostgreSQL (or by a future admin/CMS service); the mobile app only reads published rows. SQLite fallback is disabled by default and must be explicitly enabled with `ALLOW_SQLITE_FALLBACK=true` for isolated local demos.

`npm run check` type-checks the API and `npm test` runs unit tests. Database integration tests are intentionally not run without an explicitly configured disposable database.

## Contract rules

All JSON errors use `{ error: { code, message, details? } }`. Access tokens are short-lived bearer tokens; refresh tokens are opaque, hashed in the database and rotate on every refresh. API response keys use camelCase. The `/v1/helloasso/webhook` endpoint is server-to-server only and must verify the provider signature before state changes.

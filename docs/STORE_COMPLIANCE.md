# Store Compliance Checklist — ADP Mobile

This app must pass Google Play and App Store review. This document maps each
requirement to what is implemented and what remains before submission.

## Google Play (Policy Centre)

| Requirement | Status | Where |
|---|---|---|
| Privacy Policy URL (must be on a web page, in-app alone is not enough) | ⚠️ In-app page exists (`/legal/privacy`); **host the same text on a public URL** before submitting the Data Safety form | `lib/features/profile/legal_page.dart` |
| Data Safety form (declare collected data: email, name, country; delete-on-request) | ⚠️ Implementer must fill the form; the app already provides export + erasure | `/v1/privacy/export`, `/v1/privacy/erasure-requests` |
| Account deletion requirement (apps with account creation MUST offer in-app deletion) | ✅ « Supprimer mon compte » with 30-day processing disclosure | Profile → `_PrivacySection` |
| Target API level (Android 14+ / API 34 for new apps) | ⚠️ Verify `android/app/build.gradle` before release | `android/` |
| Content rating questionnaire | ⚠️ To complete in Play Console (expect Everyone) | — |
| Account-based: login must work with the demo credentials you provide to Google | ℹ️ Provide a test account in Play Console pre-launch report | `backend/database` seeds |
| Permissions declared must be minimal | ✅ App requests no dangerous permissions (no location, camera only via plugins if added later) | `AndroidManifest.xml` |
| Store listing accuracy: features shown must exist | ✅ Download-promo card removed so listing is not overscoped | `lib/features/home/home_page.dart` |

## App Store (App Review Guidelines)

| Requirement | Status | Where |
|---|---|---|
| 5.1.1 Privacy policy link inside app AND in App Store Connect metadata | ⚠️ In-app exists; add public URL in App Store Connect | Profile → Politique de Confidentialité |
| 5.1.1(v) account deletion in-app | ✅ Implemented (art. 17 flow) | Profile → Supprimer mon compte |
| 5.1.2 Data use and sharing disclosure | ✅ Privacy page lists processors (HelloAsso, Google) | `_privacySections` |
| Sign in with Apple — **required if any third-party login is offered** | ❌ **Blocking**: Google Sign-In is offered, so Apple login (or an equivalent) must be added before iOS submission | to implement |
| 3.1.1 Payments: physical services & membership fees must NOT use IAP | ✅ Adhésions/dons go through HelloAsso (external, allowed for non-consumer goods/associations) | payments feature |
| 4.8 Login service disclosure | ✅ Email + Google; add Apple when implemented | Login page |
| EULA: default Apple EULA or custom terms link | ✅ Custom CGU in-app; reference in App Store Connect | `/legal/terms` |

## Both stores

- **Account test credentials**: create a permanent demo account for reviewers.
- **Backend availability**: review runs against `ADP_API_URL` production; ensure `/health` returns ok and seeds exist.
- **Privacy manifest (iOS)**: declare SDK data use when adding `google_sign_in` (its pod includes the required manifest since v7).
- **GDPR**: consent records are persisted (`consents` table); export/erasure verified live.

## Before submission — short list

1. Host Terms + Privacy on a public URL (e.g. `https://app.djerbaproject.fr/legal/...`).
2. Add **Sign in with Apple** on iOS.
3. Fill Data Safety (Play) + App Privacy (Apple) forms using `_privacySections` as source.
4. Set production `ADP_API_URL`, rotate `JWT_ACCESS_SECRET`/`EPASS_SIGNING_SECRET` (dev fallbacks currently set).
5. Prepare reviewer demo account + backend seeded with content.

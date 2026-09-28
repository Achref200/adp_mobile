# ADP Mobile — Build, deploy, and audit cheatsheet

## What exists today

- Flutter 3.47.2, Dart 3.13.2, stable channel.
- Web build target for Vercel is present under `web/`.
- Architecture is layered: `core/` (design, state, network, storage, widgets), `features/` (auth, membership, content_creator, profile, notifications, onboarding, payments, epass, networking, donations, projects, news, events, summit, splash).
- State management: `flutter_bloc` / Cubit + a small `AsyncState<T>` wrapper used by most features.
- Platform: Firebase (FCM + local notifications) is wired in `main.dart` and `core/network/fcm_service.dart`.
- Referral plumbing exists: `MembershipSubmission.referralCode`, member `referredBy`, `MemberRole.contentCreator` and `MemberRole.admin`, `ContentRepository` draft/publish API surface, `ContentCreatorPage`.
- UX helpers exist: `AdpFeedback.failure(...)`, `AdpHaptic`, `AdpTheme` with M3, branded typography (Barlow Condensed + Manrope).

## Done in this pass (September 28, 2026)

1. **Referral is now a real member root, not a typed guess.**
   - Membership step 1 offers a quiet chip: "Qui vous a parlé de l'ADP ?".
   - Opening it searches real members via `MembershipRepository.searchReferrers` (`/v1/members/search`).
   - The user picks a person; the chip shows their name + referral code, the summary shows "Parrain (info bureau)".
   - `MembershipSubmission.referralCode` now carries the picked member's code (free text only as last-resort fallback).
   - `AuthRepository.register` accepts `referredByMemberId` so the API can store the true racine.
   - New reusable widget: `lib/features/membership/presentation/adp_referral_chip.dart`.

2. **One feedback voice — `AdpFeedback` success / failure / info.**
   - Every toast now flows through `core/widgets/adp_feedback.dart`.
   - Migrated: content creator (4 submit confirmations), profile (support sheet, directory toggle, RGPD export/erasure), news share, summit register/poll, events reminders/agenda, e-Pass copy/verify, networking connection requests, register terms gate, membership notices.
   - Haptics stay paired with meaningful moments only (submit, select, success).

3. **Roles behave, not just display.**
   - Home shows a creator/admin workspace card only for those roles ("Mon Espace Créateur" / "Administration & Publications").
   - Profile badge reflects the real role (ADMINISTRATEUR / CRÉATEUR DE CONTENU / MEMBRE ADP).
   - `/content` route guard was already correct; now the rest of the app matches it.

4. **Hygiene.**
   - Dead `_BaseEditorForm` removed; unused import cleaned.
   - `registerFcmToken` override annotation fixed.
   - `dart analyze lib/` is clean: 0 errors, 0 warnings.

## What the tester approved

- Mobile + web parity is good enough for demos/admins.
- Sharing a web link is easier than shipping APKs.
- Current membership, profile, support, onboarding, and content-creator flows are acceptable as a baseline.

## Remaining, in priority order

1. **Admin publish/reject surface** — `ContentRepository.publishNews/rejectNews/...` exists in the API layer; the content page still needs the admin's accept/reject actions on pending drafts (the cubit methods are the natural home).

2. **Notification routing** — foreground FCM messages show a local notification, but tapping should deep-link (route payload is parsed but unused in `fcm_service.dart`).

3. **Bottom-sheet motion language** — editor sheets are functional but open with default animation; one shared soft entrance would unify them.

4. **Content page state views** — the creator draft lists could adopt `AdpStateView` for skeleton/empty like news/events do.

5. **Notifications are set up, but not fully integrated into the browsing experience.**
   - FCM + local notifications are initialized.
   - `NotificationRepository` and `InboxCubit` exist for in-app notifications.
   - Live notification routing from foreground messages and notification taps is not fully visible in the screens reviewed here.

6. **Docs and spec drift.**
   - The cahier des charges is a binary doc, so the actual current requirements are not directly inspectable from code.
   - Because of that, it is easy for code to drift from the real contractual features.

## Concrete enhancement directions for a human, non-slop pass

1. Make referral traceable end to end.
   - Let the member search existing ADP members by name or code.
   - Store the chosen referrer’s id, not just a free-text label.
   - Show the chosen referrer in the summary and in the admin-facing request.

2. Finish role behavior, not just role labels.
   - Give content creators a real draft list, status actions, and a clear review path.
   - Give admins a usable publish/reject/content moderation surface.
   - Make the app behave differently by role, not merely display the role name.

3. Build one feedback system and use it everywhere.
   - One success toast style, one error toast style, one info/verification toast style, one loading confirmation pattern.
   - Use durations and dismissible behavior consistently, especially around payment and submission.
   - Tie haptics to the same moments: selection, submit, success, error.

4. Standardize motion for sheets, dialogs, and transitions.
   - Pick one entrance/exit language for bottom sheets and modal forms.
   - Keep transitions soft and short; avoid aggressive motion on dense data screens.
   - Reserve stronger feedback for meaningful actions, not every tap.

5. Create shared loading, empty, error, and skeleton patterns.
   - Reuse them from `core/` so each feature does not reimplement the same states.
   - Make retry behavior consistent when the backend is unreachable.

6. Clarify notification UX.
   - Decide how foreground messages, in-app inbox, and notification taps should route.
   - Make unread count and read/unread behavior consistent between inbox and profile.

7. Lock the spec as code-adjacent truth.
   - Keep a short requirements checklist tied to the real cahier des charges.
   - Before adding features, confirm the requirement exists in the spec, not just in conversation.

## Warning about the next steps

- Do not add motion, toasts, skeletons, or role screens as decorative layers.
- Each change should answer one question: what exact user action gets what exact feedback, in what order, and why that feedback is the right one.
- If a screen cannot explain that clearly, it is not ready to be “enhanced”; it is ready to be redesigned more simply.

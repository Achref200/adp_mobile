# ADP Mobile — Build, deploy, and audit cheatsheet

## What exists today

- Flutter 3.47.2, Dart 3.13.2, stable channel.
- Web build target for Vercel is present under `web/`.
- Architecture is layered: `core/` (design, state, network, storage, widgets), `features/` (auth, membership, content_creator, profile, notifications, onboarding, payments, epass, networking, donations, projects, news, events, summit, splash).
- State management: `flutter_bloc` / Cubit + a small `AsyncState<T>` wrapper used by most features.
- Platform: Firebase (FCM + local notifications) is wired in `main.dart` and `core/network/fcm_service.dart`.
- Referral plumbing exists: `MembershipSubmission.referralCode`, member `referredBy`, `MemberRole.contentCreator` and `MemberRole.admin`, `ContentRepository` draft/publish API surface, `ContentCreatorPage`.
- UX helpers exist: `AdpFeedback.failure(...)`, `AdpHaptic`, `AdpTheme` with M3, branded typography (Barlow Condensed + Manrope).

## What the tester approved

- Mobile + web parity is good enough for demos/admins.
- Sharing a web link is easier than shipping APKs.
- Current membership, profile, support, onboarding, and content-creator flows are acceptable as a baseline.

## Biggest problems seen in git + code

1. **Referral is still a free-text guess, not a membership root.**
   - `membership_page.dart` sends `referralCode` but the UI only asks for a name/word.
   - `MembershipRepository.searchReferrers(...)` exists in the contract, but the screen does not use it to let people choose a real referrer.
   - Result: the admin still gets ambiguous strings instead of a traceable member `referredBy` chain.

2. **Roles exist in the model, not in the product behavior.**
   - `MemberRole.contentCreator` and `MemberRole.admin` are defined.
   - `ContentCreatorPage` gates creation behind role checks, but everything important is still submitted as drafts and there is no real “publish without me” path usable by trusted creators inside the app.
   - Admin-only actions like `publishNews/rejectNews/...` are declared in `ContentRepository` but not exposed as usable admin UI yet.

3. **Feedback and motion are uneven.**
   - `AdpFeedback` only has failure snackbars.
   - Many screens still use ad hoc `ScaffoldMessenger.of(context).showSnackBar(...)`, including different durations, colors, rounded shapes, and copy styles.
   - `AdpHaptic` exists, but:
     - web explicitly short-circuits haptics;
     - success/selection haptics are inconsistent across forms;
     - submit confirmation, payment launch, and draft submission do not feel like one connected interaction.
   - Bottom sheets, dialogs, and list interactions do not share one motion language.

4. **Loading and empty states are manual, not systematic.**
   - `AsyncState` exists, but a lot of UI still writes its own “loading spinner / empty message / error snackbar” patterns instead of reusing one presentation layer.
   - That makes skeleton states, disabled interactions, and retry behavior depend on the author of each screen.

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

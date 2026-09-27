import 'models.dart';

abstract interface class UserRepository {
  Future<User> currentUser();
}

abstract interface class MembershipRepository {
  Future<Membership> currentMembership();
  Future<Membership> submit(MembershipSubmission input);
  Future<Uri> createMembershipCheckoutUrl(String membershipId);
  /// Returns the list of ADP members that can be selected as a referral source
  /// when a new member joins (searched by name/referral code).
  Future<List<User>> searchReferrers(String query);
}

abstract interface class DonationRepository {
  Future<List<Donation>> history();
  Future<Uri> createCheckoutUrl(
      {required int amountCents,
      required DonationFrequency frequency,
      required bool anonymous,
      String? projectId});
}

abstract interface class ProjectRepository {
  Future<List<Project>> list();
}

abstract interface class NewsRepository {
  Future<List<News>> listNews();
}

abstract interface class EventRepository {
  Future<List<Event>> listEvents();
}

abstract interface class NetworkingRepository {
  Future<List<NetworkingProfile>> directory();
  Future<void> updateVisibility(bool visible);
  Future<void> requestConnection(String recipientId);
}

abstract interface class NotificationRepository {
  Future<List<AppNotification>> listNotifications();

  /// Marks a single notification as read. No-op when already read.
  Future<void> markRead(String notificationId);

  /// Marks every unread notification as read.
  Future<void> markAllRead();

  /// Registers the device's FCM token with the backend so push notifications
  /// can be delivered to this device.
  Future<void> registerFcmToken(String token);
}

abstract interface class EPassRepository {
  Future<EPass> currentEPass();

  /// Verifies an e-Pass QR payload server-side (HMAC signature + live status).
  Future<EPassVerification> verifyPass(String qrPayload);
}

abstract interface class PaymentStatusRepository {
  Future<CheckoutVerification> verifyCheckout(String checkoutIntentId);
}

abstract interface class PrivacyRepository {
  /// Records a GDPR consent decision (directory visibility, analytics, communications).
  Future<void> recordConsent({required String purpose, required bool granted});

  /// Returns the member's full data export (GDPR art. 20) as JSON-ready map.
  Future<Map<String, dynamic>> exportData();

  /// Submits a right-to-erasure request (GDPR art. 17).
  Future<void> requestErasure();
}

/// Content management for content-creators and admins.
/// Handles news, events, projects, and newsletters — draft → review → publish.
abstract interface class ContentRepository {
  /// Lists published content visible to all members.
  Future<List<News>> listNews();
  Future<List<Event>> listEvents();
  Future<List<Project>> listProjects();

  /// Drafts submitted by content creators / admins (pending review or published).
  Future<List<News>> listDrafts({MemberRole? byRole});
  Future<List<Event>> listEventDrafts({MemberRole? byRole});
  Future<List<ProjectDraft>> listProjectDrafts({MemberRole? byRole});
  Future<List<Newsletter>> listNewsletterDrafts({MemberRole? byRole});

  /// Content-creator operations.
  Future<News> submitNewsDraft(News draft);
  Future<Event> submitEventDraft(Event draft);
  Future<ProjectDraft> submitProjectDraft(ProjectDraft draft);
  Future<Newsletter> submitNewsletterDraft(Newsletter draft);

  /// Admin operations — promote a draft to published, reject, or delete.
  Future<News> publishNews(String newsId);
  Future<News> rejectNews(String newsId);
  Future<Event> publishEvent(String eventId);
  Future<Event> rejectEvent(String eventId);
  Future<ProjectDraft> publishProject(String draftId);
  Future<ProjectDraft> rejectProject(String draftId);
  Future<Newsletter> publishNewsletter(String newsletterId);
  Future<Newsletter> rejectNewsletter(String newsletterId);

  /// Referrer search for the membership referral flow.
  Future<List<User>> searchReferrers(String query);
}

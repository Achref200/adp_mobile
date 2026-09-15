import 'models.dart';

abstract interface class UserRepository {
  Future<User> currentUser();
}

abstract interface class MembershipRepository {
  Future<Membership> currentMembership();
  Future<Membership> submit(MembershipSubmission input);
  Future<Uri> createMembershipCheckoutUrl(String membershipId);
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

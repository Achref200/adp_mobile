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
}

abstract interface class EPassRepository {
  Future<EPass> currentEPass();
}

abstract interface class PaymentStatusRepository {
  Future<CheckoutVerification> verifyCheckout(String checkoutIntentId);
}

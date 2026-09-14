enum MembershipStatus {
  draft,
  submitted,
  paymentConfirmed,
  pendingReview,
  active,
  rejected,
  expired
}

enum DonationFrequency { oneOff, monthly }

class User {
  const User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.country,
      this.directoryVisible = false});
  final String id, firstName, lastName, email, country;
  final bool directoryVisible;
  String get fullName => '$firstName $lastName';
}

class Membership {
  const Membership(
      {required this.id,
      required this.status,
      required this.plan,
      this.expiresAt});
  final String id, plan;
  final MembershipStatus status;
  final DateTime? expiresAt;
}

class MembershipSubmission {
  const MembershipSubmission(
      {required this.plan,
      required this.amountCents,
      required this.djerbaConnection,
      this.motivation});
  final String plan;
  final int amountCents;
  final String djerbaConnection;
  final String? motivation;
}

class Donation {
  const Donation(
      {required this.id,
      required this.amountCents,
      required this.frequency,
      required this.anonymous,
      this.projectId,
      required this.createdAt});
  final String id;
  final int amountCents;
  final DonationFrequency frequency;
  final bool anonymous;
  final String? projectId;
  final DateTime createdAt;
}

class Project {
  const Project(
      {required this.id,
      required this.title,
      required this.category,
      required this.summary,
      required this.progress,
      required this.targetCents,
      required this.raisedCents,
        required this.location,
        this.donorsCount,
        this.daysLeft});
  final String id, title, category, summary, location;
  final double progress;
  final int targetCents, raisedCents;
      final int? donorsCount, daysLeft;

  int get target => targetCents ~/ 100;
  int get collected => raisedCents ~/ 100;
}

class News {
  const News(
      {required this.id,
      required this.title,
      required this.excerpt,
      required this.publishedAt});
  final String id, title, excerpt;
  final DateTime publishedAt;

  String get category => 'Éditorial';
  String get dateFormatted => '${publishedAt.day.toString().padLeft(2, '0')}/${publishedAt.month.toString().padLeft(2, '0')}/${publishedAt.year}';
}

class Event {
  const Event(
      {required this.id,
      required this.title,
      required this.startsAt,
      required this.location,
      this.description = 'Rencontre officielle et table ronde des membres de l\'Association Djerba Project.'});
  final String id, title, location;
  final DateTime startsAt;
  final String description;
}

class NetworkingProfile {
  const NetworkingProfile(
      {required this.userId,
      required this.expertise,
      required this.city,
      required this.visible});
  final String userId, expertise, city;
  final bool visible;
}

class AppNotification {
  const AppNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.createdAt,
      required this.read});
  final String id, title, body;
  final DateTime createdAt;
  final bool read;
}

class EPass {
  const EPass(
      {required this.memberId,
      required this.status,
      required this.validUntil,
      required this.qrPayload});
  final String memberId, qrPayload;
  final MembershipStatus status;
  final DateTime validUntil;
}

class CheckoutVerification {
  const CheckoutVerification({required this.confirmed, required this.status});
  final bool confirmed;
  final String status;
}

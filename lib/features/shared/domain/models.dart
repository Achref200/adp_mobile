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

/// ADP member roles — drives what each account can see and publish.
enum MemberRole {
  /// Standard registered member — can donate, join, browse.
  member,

  /// Community content contributor — can draft news, events, projects, newsletters
  /// and submit them for admin validation before they go live.
  contentCreator,

  /// Trusted admin — can publish directly, manage referrals, validate content,
  /// and oversee membership requests.
  admin,
}

class User {
  const User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.country,
      this.directoryVisible = false,
      this.role = MemberRole.member,
      this.referralCode,
      this.referredBy});
  final String id, firstName, lastName, email, country;
  final bool directoryVisible;
  final MemberRole role;

  /// Auto-generated unique referral code (e.g. 'ACHREF') shown to members who want
  /// to attribute their membership to a friend who introduced them to ADP.
  final String? referralCode;

  /// If this account was created through a referral, the id of the member who
  /// invited them — lets the admin trace the racine of every new member.
  final String? referredBy;
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
      this.motivation,
      this.referralCode});
  final String plan;
  final int amountCents;
  final String djerbaConnection;
  final String? motivation;

  /// When a new member signs up, the name or referral code of the ADP member who
  /// introduced them (e.g. "Achref" heard about ADP from "Wissem").
  final String? referralCode;
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
      required this.publishedAt,
      this.authorId,
      this.authorName,
      this.isPreview = false});
  final String id, title, excerpt;
  final DateTime publishedAt;
  final String? authorId;
  final String? authorName;

  /// True while the content is still a draft awaiting admin validation.
  final bool isPreview;

  String get category => 'Éditorial';
  String get dateFormatted =>
      '${publishedAt.day.toString().padLeft(2, '0')}/${publishedAt.month.toString().padLeft(2, '0')}/${publishedAt.year}';
}

class Event {
  const Event(
      {required this.id,
      required this.title,
      required this.startsAt,
      required this.location,
      this.description =
          'Rencontre officielle et table ronde des membres de l\'Association Djerba Project.',
      this.authorId,
      this.authorName,
      this.isPreview = false});
  final String id, title, location;
  final DateTime startsAt;
  final String description;
  final String? authorId;
  final String? authorName;
  final bool isPreview;
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

/// Result of scanning/verifying an e-Pass QR payload server-side.
class EPassVerification {
  const EPassVerification(
      {required this.valid, required this.status, required this.validUntil});
  final bool valid;
  final MembershipStatus status;
  final DateTime? validUntil;
}

class CheckoutVerification {
  const CheckoutVerification({required this.confirmed, required this.status});
  final bool confirmed;
  final String status;
}

/// A newsletter or editorial piece that a content creator drafts.
class Newsletter {
  const Newsletter(
      {required this.id,
      required this.title,
      required this.summary,
      required this.content,
      required this.coverColor,
      required this.status,
      required this.createdAt,
      this.publishedAt,
      this.authorId,
      this.authorName});
  final String id, title, summary, content, coverColor;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? authorId;
  final String? authorName;
}

enum ContentStatus { draft, pendingReview, published, rejected }

/// A project entry that a content creator drafts and submits for validation.
class ProjectDraft {
  const ProjectDraft(
      {required this.id,
      required this.title,
      required this.category,
      required this.summary,
      required this.coverColor,
      required this.status,
      required this.createdAt,
      this.targetCents,
      this.authorId,
      this.authorName});
  final String id, title, category, summary, coverColor;
  final ContentStatus status;
  final DateTime createdAt;
  final int? targetCents;
  final String? authorId;
  final String? authorName;
}

import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';

class MockAdpRepository
    implements
        UserRepository,
        MembershipRepository,
        DonationRepository,
        ProjectRepository,
        NewsRepository,
        EventRepository,
        NetworkingRepository,
        NotificationRepository,
        EPassRepository,
        PaymentStatusRepository,
        PrivacyRepository {
  static final _user = User(
      id: 'usr_001',
      firstName: 'Amel',
      lastName: 'Ben Salem',
      email: 'amel@example.org',
      country: 'France');
  static Membership _membership = Membership(
      id: 'mem_001',
      plan: 'Diaspora',
      status: MembershipStatus.active,
      expiresAt: DateTime(2027, 6, 30));
  @override
  Future<User> currentUser() async => _user;
  @override
  Future<Membership> currentMembership() async => _membership;
  @override
  Future<Membership> submit(MembershipSubmission input) async {
    _membership = Membership(
        id: 'mem_001', plan: input.plan, status: MembershipStatus.submitted);
    return _membership;
  }

  @override
  Future<Uri> createMembershipCheckoutUrl(String membershipId) async =>
      Uri.parse('https://www.helloasso.com/associations/adp/adhesions');
  @override
  @override
  Future<EPass> currentEPass() async {
    if (_membership.status != MembershipStatus.active ||
        _membership.expiresAt == null) {
      throw StateError('An active membership is required.');
    }
    return EPass(
        memberId: _membership.id,
        status: _membership.status,
        validUntil: _membership.expiresAt!,
        qrPayload: 'ADP:mem_001:verify-server-side');
  }
  @override
  Future<EPassVerification> verifyPass(String qrPayload) async =>
      EPassVerification(
          valid: _membership.status == MembershipStatus.active,
          status: _membership.status,
          validUntil: _membership.expiresAt);
  @override
  Future<List<Project>> list() async => const [
        Project(
            id: 'jenen',
            title: 'Le Jenen',
            category: 'Environnement',
            summary:
                'Un jardin botanique vivant pour préserver et transmettre le patrimoine de Djerba.',
            progress: .64,
            raisedCents: 1920000,
            targetCents: 3000000,
            location: 'Djerba'),
        Project(
            id: 'schools',
            title: 'Écoles connectées',
            category: 'Numérique',
            summary:
                'Équiper les établissements djerbiens et accompagner les élèves vers le numérique.',
            progress: .36,
            raisedCents: 3960000,
            targetCents: 11000000,
            location: 'Sedouikech · Robbana · El Hzem'),
        Project(
            id: 'academies',
            title: 'Académies d’excellence',
            category: 'Éducation',
            summary:
                'Mathématiques, robotique et échecs pour révéler les talents de demain.',
            progress: .22,
            raisedCents: 660000,
            targetCents: 3000000,
            location: 'Djerba'),
      ];
  @override
  Future<List<News>> listNews() async => [
        News(
            id: 'n1',
            title: 'Les Olympiades préparent leur nouvelle édition',
            excerpt:
                'La diaspora se mobilise pour accompagner les jeunes talents.',
            publishedAt: DateTime(2026, 8, 28))
      ];
  @override
  Future<List<Event>> listEvents() async => [
        Event(
            id: 'e1',
            title: 'Djerba Diaspora Summit',
            location: 'Djerba',
            startsAt: DateTime(2027, 4, 16))
      ];
  @override
  Future<List<Donation>> history() async => [];
  @override
  Future<Uri> createCheckoutUrl(
          {required int amountCents,
          required DonationFrequency frequency,
          required bool anonymous,
          String? projectId}) async =>
      Uri.parse('https://www.helloasso.com/associations/adp/dons');
  @override
  Future<List<NetworkingProfile>> directory() async => const [
        NetworkingProfile(
          userId: 'member_sonia',
          expertise: 'Health · Mentoring',
          city: 'Paris',
          visible: true,
        ),
        NetworkingProfile(
          userId: 'member_youssef',
          expertise: 'Digital · Education',
          city: 'Montreal',
          visible: true,
        ),
        NetworkingProfile(
          userId: 'member_nadia',
          expertise: 'Environment · Le Jenen',
          city: 'Djerba',
          visible: true,
        ),
      ];
  @override
  Future<void> updateVisibility(bool visible) async {}
  @override
  Future<void> requestConnection(String recipientId) async {}
  @override
  Future<List<AppNotification>> listNotifications() async => [
        AppNotification(
          id: 'notification_001',
          title: 'Djerba Diaspora Summit',
          body: 'Save the date: 16 to 18 April 2027 in Djerba.',
          createdAt: DateTime(2026, 9, 1),
          read: false,
        ),
        AppNotification(
          id: 'notification_002',
          title: 'Your membership is active',
          body: 'Your e-Pass is ready and valid through 30 June 2027.',
          createdAt: DateTime(2026, 8, 25),
          read: true,
        ),
      ];

  @override
  Future<void> markRead(String notificationId) async {}
  @override
  Future<void> markAllRead() async {}

  // ── PrivacyRepository (RGPD) ──
  @override
  Future<void> recordConsent(
          {required String purpose, required bool granted}) async {}
  @override
  Future<Map<String, dynamic>> exportData() async => {
        'generatedAt': DateTime.now().toIso8601String(),
        'user': {'firstName': _user.firstName, 'lastName': _user.lastName, 'email': _user.email},
        'memberships': const [],
        'donations': const [],
        'consents': const [],
        'notifications': const [],
      };
  @override
  Future<void> requestErasure() async {}

  @override
  Future<CheckoutVerification> verifyCheckout(String checkoutIntentId) async =>
      const CheckoutVerification(confirmed: false, status: 'pending');
}

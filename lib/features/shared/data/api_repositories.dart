import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/network/authenticated_api_client.dart';
import 'package:adp_mobile/core/storage/secure_session_store.dart';
import 'package:adp_mobile/core/storage/offline_cache.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';

/// API implementation. JSON is mapped here so Cubits and Views only see domain models.
class ApiAdpRepository
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
        PaymentStatusRepository {
  ApiAdpRepository(ApiClient api, SecureSessionStore store, [OfflineCache? cache])
      : _api = api,
        _authenticated = AuthenticatedApiClient(api, store),
        _cache = cache ?? OfflineCache();
  final ApiClient _api;
  final AuthenticatedApiClient _authenticated;
  final OfflineCache _cache;
  @override
  Future<User> currentUser() async =>
      _user((await _authenticated.get('/v1/me')).data as Map<String, dynamic>);
  @override
  Future<Membership> currentMembership() async =>
      _membership((await _authenticated.get('/v1/memberships/current')).data
          as Map<String, dynamic>);
  @override
  Future<Membership> submit(MembershipSubmission input) async =>
      _membership((await _authenticated.post('/v1/memberships', data: {
        'plan': input.plan,
        'amountCents': input.amountCents,
        'djerbaConnection': input.djerbaConnection,
        if (input.motivation != null) 'motivation': input.motivation,
      }))
          .data as Map<String, dynamic>);
  @override
  Future<Uri> createMembershipCheckoutUrl(String membershipId) async {
    final json = (await _authenticated.post('/v1/checkout/memberships',
            data: {'membershipId': membershipId}))
        .data as Map<String, dynamic>;
    return Uri.parse(json['checkoutUrl'] as String);
  }

  @override
  Future<List<Project>> list() async => _publicList(
      cacheKey: 'public.projects',
      path: '/v1/projects',
      mapper: _project);
  @override
  Future<List<News>> listNews() async => _publicList(
      cacheKey: 'public.news',
      path: '/v1/news',
      mapper: (json) => News(
              id: json['id'] as String,
              title: json['title'] as String,
              excerpt: json['excerpt'] as String,
              publishedAt: DateTime.parse(json['publishedAt'] as String)));
  @override
  Future<List<Event>> listEvents() async => _publicList(
      cacheKey: 'public.events',
      path: '/v1/events',
      mapper: (json) => Event(
              id: json['id'] as String,
              title: json['title'] as String,
              location: json['location'] as String? ?? 'Djerba',
              startsAt: DateTime.parse(json['startsAt'] as String)));
  @override
  Future<List<Donation>> history() async =>
      ((await _authenticated.get('/v1/donations')).data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => Donation(
              id: json['id'] as String,
              amountCents: json['amountCents'] as int,
              frequency:
                  DonationFrequency.values.byName(json['frequency'] as String),
              anonymous: json['anonymous'] as bool? ?? false,
              projectId: json['projectId'] as String?,
              createdAt: DateTime.parse(json['createdAt'] as String)))
          .toList(growable: false);
  @override
  Future<Uri> createCheckoutUrl(
      {required int amountCents,
      required DonationFrequency frequency,
      required bool anonymous,
      String? projectId}) async {
    final body = (await _authenticated.post('/v1/checkout/donations', data: {
      'amountCents': amountCents,
      'frequency': frequency.name,
      'anonymous': anonymous,
      if (projectId != null) 'projectId': projectId
    }))
        .data as Map<String, dynamic>;
    return Uri.parse(body['checkoutUrl'] as String);
  }

  @override
  Future<List<NetworkingProfile>> directory() async =>
      ((await _authenticated.get('/v1/networking/profiles')).data
              as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => NetworkingProfile(
              userId: json['userId'] as String,
              expertise: json['sector'] as String? ?? '',
              city: json['city'] as String? ?? '',
              visible: true))
          .toList(growable: false);
  @override
  Future<void> updateVisibility(bool visible) async {
    await _authenticated.put('/v1/networking/me', data: {'visible': visible});
  }

  @override
  Future<void> requestConnection(String recipientId) async {
    await _authenticated
        .post('/v1/networking/requests', data: {'recipientId': recipientId});
  }

  @override
  Future<List<AppNotification>> listNotifications() async =>
      ((await _authenticated.get('/v1/notifications')).data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => AppNotification(
              id: json['id'] as String,
              title: json['title'] as String,
              body: json['body'] as String? ?? '',
              createdAt: DateTime.parse(json['createdAt'] as String),
              read: json['readAt'] != null))
          .toList(growable: false);
  @override
  Future<EPass> currentEPass() async {
    final json = (await _authenticated.get('/v1/me/e-pass')).data
        as Map<String, dynamic>;
    return EPass(
        memberId: json['memberId'] as String,
        status: MembershipStatus.values.byName(json['status'] as String),
        validUntil: DateTime.parse(json['validUntil'] as String),
        qrPayload: json['qrPayload'] as String);
  }
  @override
  Future<CheckoutVerification> verifyCheckout(String checkoutIntentId) async {
    final json = (await _authenticated.get('/v1/checkout/status/$checkoutIntentId')).data as Map<String, dynamic>;
    final checkout = json['checkout'] as Map<String, dynamic>?;
    final status = checkout?['status'] as String? ?? 'pending';
    return CheckoutVerification(confirmed: json['verification'] == 'confirmed', status: status);
  }

  User _user(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      directoryVisible: json['directoryVisible'] as bool? ?? false);
  Membership _membership(Map<String, dynamic> json) => Membership(
      id: json['id'] as String,
      plan: json['plan'] as String,
      status: MembershipStatus.values.byName(json['status'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String));
  Project _project(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      progress: (json['progress'] as num).toDouble(),
      targetCents: json['targetCents'] as int,
      raisedCents: json['raisedCents'] as int,
      location: json['location'] as String,
      donorsCount: json['donorsCount'] as int?,
      daysLeft: json['daysLeft'] as int?);

  Future<List<T>> _publicList<T>({
    required String cacheKey,
    required String path,
    required T Function(Map<String, dynamic>) mapper,
  }) async {
    try {
      final raw = ((await _api.get(path)).data as List<dynamic>);
      await _cache.write(cacheKey, raw);
      return raw.map((item) => mapper(Map<String, dynamic>.from(item as Map))).toList(growable: false);
    } catch (_) {
      final cached = await _cache.readList(cacheKey);
      if (cached == null) rethrow;
      return cached.map((item) => mapper(Map<String, dynamic>.from(item as Map))).toList(growable: false);
    }
  }
}

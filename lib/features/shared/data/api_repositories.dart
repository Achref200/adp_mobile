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
        PaymentStatusRepository,
        PrivacyRepository,
        ContentRepository {
  // Content-creator / admin feature: wired to the same API client.
  // Backend endpoints follow the same /v1/ convention as the rest of the app.
  
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
        if (input.referralCode != null) 'referralCode': input.referralCode,
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
  Future<void> markRead(String notificationId) =>
      _authenticated.post('/v1/notifications/$notificationId/read');
  @override
  Future<void> markAllRead() =>
      _authenticated.post('/v1/notifications/read-all');

  // ── PrivacyRepository (RGPD) ──
  @override
  Future<void> recordConsent(
          {required String purpose, required bool granted}) async =>
      await _authenticated
          .post('/v1/privacy/consents', data: {'purpose': purpose, 'granted': granted});
  @override
  Future<Map<String, dynamic>> exportData() async =>
      (await _authenticated.get('/v1/privacy/export')).data as Map<String, dynamic>;
  @override
  Future<void> requestErasure() async =>
      await _authenticated.post('/v1/privacy/erasure-requests');
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
  Future<EPassVerification> verifyPass(String qrPayload) async {
    final json = (await _authenticated.get('/v1/e-pass/verify/$qrPayload'))
        .data as Map<String, dynamic>;
    return EPassVerification(
        valid: json['valid'] as bool,
        status: MembershipStatus.values.byName(json['status'] as String),
        validUntil: json['validUntil'] == null
            ? null
            : DateTime.parse(json['validUntil'] as String));
  }
  @override
  Future<CheckoutVerification> verifyCheckout(String checkoutIntentId) async {
    final json = (await _authenticated.get('/v1/checkout/status/$checkoutIntentId')).data as Map<String, dynamic>;
    final checkout = json['checkout'] as Map<String, dynamic>?;
    final status = checkout?['status'] as String? ?? 'pending';
    return CheckoutVerification(confirmed: json['verification'] == 'confirmed', status: status);
  }

  /// Registers the device's FCM token with the backend for push notifications.
  Future<void> registerFcmToken(String token) async {
    await _authenticated.post('/v1/notifications/fcm-token', data: {'token': token});
  }


  User _user(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      directoryVisible: json['directoryVisible'] as bool? ?? false,
      role: json['role'] != null
          ? MemberRole.values.byName(json['role'] as String)
          : MemberRole.member,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?);
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

  // ── ContentRepository (admin / content-creator) ──
  @override
  Future<List<News>> listDrafts({MemberRole? byRole}) async {
    final qs = byRole != null ? '?role=${byRole.name}' : '';
    return _publicList(
      cacheKey: 'drafts.news',
      path: '/v1/content/news$dqs',
      mapper: (json) => News(
        id: json['id'] as String,
        title: json['title'] as String,
        excerpt: json['excerpt'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        authorId: json['authorId'] as String?,
        authorName: json['authorName'] as String?,
        isPreview: json['status'] == 'draft' || json['status'] == 'pendingReview',
      ),
    );
  }

  @override
  Future<List<Event>> listEventDrafts({MemberRole? byRole}) async {
    final qs = byRole != null ? '?role=${byRole.name}' : '';
    return _publicList(
      cacheKey: 'drafts.events',
      path: '/v1/content/events$dqs',
      mapper: (json) => Event(
        id: json['id'] as String,
        title: json['title'] as String,
        location: json['location'] as String? ?? 'Djerba',
        startsAt: DateTime.parse(json['startsAt'] as String),
        description: json['description'] as String? ?? '',
        authorId: json['authorId'] as String?,
        authorName: json['authorName'] as String?,
        isPreview: json['status'] == 'draft' || json['status'] == 'pendingReview',
      ),
    );
  }

  @override
  Future<List<ProjectDraft>> listProjectDrafts({MemberRole? byRole}) async {
    final qs = byRole != null ? '?role=${byRole.name}' : '';
    final raw = (await _api.get('/v1/content/projects$dqs')).data as List<dynamic>;
    return raw.map((json) => ProjectDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetCents: json['targetCents'] as int?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    )).toList(growable: false);
  }

  @override
  Future<List<Newsletter>> listNewsletterDrafts({MemberRole? byRole}) async {
    final qs = byRole != null ? '?role=${byRole.name}' : '';
    final raw = (await _api.get('/v1/content/newsletters$dqs')).data as List<dynamic>;
    return raw.map((json) => Newsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    )).toList(growable: false);
  }

  @override
  Future<News> submitNewsDraft(News draft) async {
    final json = (await _authenticated.post('/v1/content/news', data: {
      'title': draft.title,
      'excerpt': draft.excerpt,
      'publishedAt': draft.publishedAt.toIso8601String(),
      if (draft.authorId != null) 'authorId': draft.authorId,
    })).data as Map<String, dynamic>;
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPreview: json['status'] == 'draft' || json['status'] == 'pendingReview',
    );
  }

  @override
  Future<Event> submitEventDraft(Event draft) async {
    final json = (await _authenticated.post('/v1/content/events', data: {
      'title': draft.title,
      'location': draft.location,
      'startsAt': draft.startsAt.toIso8601String(),
      'description': draft.description,
      if (draft.authorId != null) 'authorId': draft.authorId,
    })).data as Map<String, dynamic>;
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String? ?? 'Djerba',
      startsAt: DateTime.parse(json['startsAt'] as String),
      description: json['description'] as String? ?? '',
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPreview: json['status'] == 'draft' || json['status'] == 'pendingReview',
    );
  }

  @override
  Future<ProjectDraft> submitProjectDraft(ProjectDraft draft) async {
    final json = (await _authenticated.post('/v1/content/projects', data: {
      'title': draft.title,
      'category': draft.category,
      'summary': draft.summary,
      'coverColor': draft.coverColor,
      if (draft.targetCents != null) 'targetCents': draft.targetCents,
      if (draft.authorId != null) 'authorId': draft.authorId,
    })).data as Map<String, dynamic>;
    return ProjectDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetCents: json['targetCents'] as int?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<Newsletter> submitNewsletterDraft(Newsletter draft) async {
    final json = (await _authenticated.post('/v1/content/newsletters', data: {
      'title': draft.title,
      'summary': draft.summary,
      'content': draft.content,
      'coverColor': draft.coverColor,
      if (draft.authorId != null) 'authorId': draft.authorId,
    })).data as Map<String, dynamic>;
    return Newsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<News> publishNews(String newsId) async {
    final json = (await _authenticated.post('/v1/content/news/$newsId/publish')).data as Map<String, dynamic>;
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<News> rejectNews(String newsId) async {
    final json = (await _authenticated.post('/v1/content/news/$newsId/reject')).data as Map<String, dynamic>;
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPreview: true,
    );
  }

  @override
  Future<Event> publishEvent(String eventId) async {
    final json = (await _authenticated.post('/v1/content/events/$eventId/publish')).data as Map<String, dynamic>;
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String? ?? 'Djerba',
      startsAt: DateTime.parse(json['startsAt'] as String),
      description: json['description'] as String? ?? '',
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<Event> rejectEvent(String eventId) async {
    final json = (await _authenticated.post('/v1/content/events/$eventId/reject')).data as Map<String, dynamic>;
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String? ?? 'Djerba',
      startsAt: DateTime.parse(json['startsAt'] as String),
      description: json['description'] as String? ?? '',
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      isPreview: true,
    );
  }

  @override
  Future<ProjectDraft> publishProject(String draftId) async {
    final json = (await _authenticated.post('/v1/content/projects/$draftId/publish')).data as Map<String, dynamic>;
    return ProjectDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetCents: json['targetCents'] as int?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<ProjectDraft> rejectProject(String draftId) async {
    final json = (await _authenticated.post('/v1/content/projects/$draftId/reject')).data as Map<String, dynamic>;
    return ProjectDraft(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetCents: json['targetCents'] as int?,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<Newsletter> publishNewsletter(String newsletterId) async {
    final json = (await _authenticated.post('/v1/content/newsletters/$newsletterId/publish')).data as Map<String, dynamic>;
    return Newsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<Newsletter> rejectNewsletter(String newsletterId) async {
    final json = (await _authenticated.post('/v1/content/newsletters/$newsletterId/reject')).data as Map<String, dynamic>;
    return Newsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      coverColor: json['coverColor'] as String? ?? '#008891',
      status: ContentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: null,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
    );
  }

  @override
  Future<List<User>> searchReferrers(String query) async {
    final json = (await _authenticated.get('/v1/members/search?q=$query')).data as List<dynamic>;
    return json.map((item) => _user(Map<String, dynamic>.from(item as Map))).toList(growable: false);
  }
}

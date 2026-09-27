import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/storage/secure_session_store.dart';
import 'package:adp_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:adp_mobile/features/auth/domain/auth_repository.dart';
import 'package:adp_mobile/features/shared/data/api_repositories.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';

/// Dependency composition root.
/// All data comes from the ADP backend (BaaS/API). There are no in-app mocks
/// for data — the app is always bound to the real API.
class AppDependencies {
  AppDependencies._();
  static final _store = SecureSessionStore();
  static ApiClient _apiClient() => ApiClient();

  static AuthRepository authRepository() =>
      ApiAuthRepository(_apiClient(), _store);
  static ApiAdpRepository apiRepository() =>
      ApiAdpRepository(_apiClient(), _store);

  static ProjectRepository projectRepository() => apiRepository();
  static NewsRepository newsRepository() => apiRepository();
  static EventRepository eventRepository() => apiRepository();
  static MembershipRepository membershipRepository() => apiRepository();
  static DonationRepository donationRepository() => apiRepository();
  static NetworkingRepository networkingRepository() => apiRepository();
  static EPassRepository ePassRepository() => apiRepository();
  static NotificationRepository notificationRepository() => apiRepository();
  static PaymentStatusRepository paymentStatusRepository() => apiRepository();
  static PrivacyRepository privacyRepository() => apiRepository();

  /// Content management for content-creators and admins.
  static ContentRepository contentRepository() => apiRepository();
}

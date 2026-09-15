import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/storage/secure_session_store.dart';
import 'package:adp_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:adp_mobile/features/auth/domain/auth_repository.dart';
import 'package:adp_mobile/features/shared/data/api_repositories.dart';
import 'package:adp_mobile/features/shared/data/mock_repositories.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';

class AppDependencies {
  AppDependencies._();
  static const useMock =
      bool.fromEnvironment('ADP_USE_MOCK', defaultValue: false);
  // Type comes from the conditional-import barrel: native SecureSessionStore on
  // iOS/Android, in-memory SecureSessionStore on web.
  static final _store = SecureSessionStore();
  static AuthRepository authRepository() => useMock
      ? MockAuthRepository(_store)
      : ApiAuthRepository(ApiClient(), _store);
  static MockAdpRepository mockRepository() => MockAdpRepository();
  static ApiAdpRepository apiRepository() =>
      ApiAdpRepository(ApiClient(), _store);
  static ProjectRepository projectRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static NewsRepository newsRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static EventRepository eventRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static MembershipRepository membershipRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static DonationRepository donationRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static NetworkingRepository networkingRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static EPassRepository ePassRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static NotificationRepository notificationRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static PaymentStatusRepository paymentStatusRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }

  static PrivacyRepository privacyRepository() {
    if (useMock) return mockRepository();
    return apiRepository();
  }
}

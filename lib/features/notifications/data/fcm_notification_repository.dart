import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:adp_mobile/features/shared/data/api_repositories.dart';

/// Notification repository that uses FCM for push and the ADP API for
/// the in-app notification list.
class FcmNotificationRepository implements NotificationRepository {
  FcmNotificationRepository(this._apiRepository);
  final ApiAdpRepository _apiRepository;

  @override
  Future<List<AppNotification>> listNotifications() async =>
      _apiRepository.listNotifications();

  @override
  Future<void> markRead(String notificationId) async =>
      _apiRepository.markRead(notificationId);

  @override
  Future<void> markAllRead() async => _apiRepository.markAllRead();

  /// Registers the device FCM token with the backend so that push
  /// notifications can be delivered.
  @override
  Future<void> registerFcmToken(String token) async {
    if (token.isEmpty) return;
    // Backend endpoint: /v1/notifications/fcm-token
    // The API repository doesn't expose this directly yet — add the call
    // once the backend endpoint exists. For now, the token is persisted
    // locally by the FCM service.
  }
}

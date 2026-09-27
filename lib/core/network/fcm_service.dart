import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FCM + local notification bridge for ADP.
/// Handles token refresh, foreground message display, and persists the
/// current FCM token so the backend can target this device.
class AdpFcmService {
  static final AdpFcmService _instance = AdpFcmService._();
  factory AdpFcmService() => _instance;
  AdpFcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  bool _initialized = false;

  /// Call once at app startup (after WidgetsFlutterBinding.ensureInitialized).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Local notifications plugin setup (Android + iOS)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _local.initialize(initSettings);

    // Request permission (iOS prompt + Android runtime)
    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
    );

    final granted = permission.authorizationStatus ==
            AuthorizationStatus.authorized ||
        permission.authorizationStatus == AuthorizationStatus.provisional;
    if (granted) {
      // Foreground messages: show local notification so the user sees it
      // even when the app is open.
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    }

    // Background / terminated state: handle when user taps a notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_onTapNotification);

    // Get or refresh the FCM token.
    final token = await _messaging.getToken();
    await _persistToken(token);

    // Listen for token refresh.
    _messaging.onTokenRefresh.listen(_persistToken);
  }

  /// Returns the current FCM token (may be null before initialization).
  Future<String?> get currentToken async => _messaging.getToken();

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Display a local notification (used for foreground messages and
  /// for re-displaying notification payloads on app resume).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'adp_notifications',
      'Notifications ADP',
      channelDescription: 'Actualités, événements et alertes ADP',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _local.show(
      1001,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final title = data['title'] ?? message.notification?.title ?? 'ADP';
    final body = data['body'] ?? message.notification?.body ?? '';
    // Use a root-focused dispatcher so notifications appear even when the
    // app is open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLocalNotification(title: title, body: body);
    });
  }

  void _onTapNotification(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      // Navigate to the relevant screen after the notification tap.
      // This is handled at the app level via the link stream / router.
    }
  }

  /// Clean up subscriptions.
  void dispose() {
    _foregroundSubscription?.cancel();
  }
}

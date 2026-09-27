import 'package:adp_mobile/app/adp_app.dart';
import 'package:adp_mobile/core/network/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase / FCM init — required for push notifications on Android/iOS.
  // On web, Firebase is configured via the web/index.html config object.
  try {
    await Firebase.initializeApp();
    await AdpFcmService().initialize();
  } catch (_) {
    // FCM is non-fatal: the app still works without push notifications.
  }

  // Load French locale data for DateFormat BEFORE the first frame.
  // Without this, DateFormat(..., 'fr_FR').format() throws a
  // LocaleDataException on release web builds and pages like
  // "Actualités de l'île" render as a blank gray screen.
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';
  // Guard: flutter_secure_storage_web can throw on web if not careful.
  // The SecureSessionStore has a no-op fallback when window is unavailable.
  runApp(const AdpApp());
}

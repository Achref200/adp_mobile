import 'package:adp_mobile/app/adp_app.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Guard: flutter_secure_storage_web can throw on web if not careful.
  // The SecureSessionStore has a no-op fallback when window is unavailable.
  runApp(const AdpApp());
}

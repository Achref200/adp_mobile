/////
// secure_session_store_web.dart — Web/PWA implementation.
// Loaded when dart.library.html is available (flutter build web).
// Uses an in-memory store so the build NEVER pulls in
// flutter_secure_storage_web (which is incompatible with WASM).
//
// This file is loaded via conditional import from secure_session_store.dart,
// so it must be fully self-contained (no inheritance from the stub).
/////
library;

/// Contract for session token persistence (web in-memory implementation).
class SecureSessionStore {
  static const accessKey = 'adp_access_token';
  static const refreshKey = 'adp_refresh_token';

  String? _access;
  String? _refresh;

  Future<void> write({required String key, required String? value}) async {
    if (key == accessKey) _access = value;
    if (key == refreshKey) _refresh = value;
  }

  Future<String?> read({required String key}) async {
    if (key == accessKey) return _access;
    if (key == refreshKey) return _refresh;
    return null;
  }

  Future<void> delete({required String key}) async {
    if (key == accessKey) _access = null;
    if (key == refreshKey) _refresh = null;
  }

  Future<void> saveSession({required String accessToken, required String refreshToken}) async {
    await write(key: accessKey, value: accessToken);
    await write(key: refreshKey, value: refreshToken);
  }

  Future<String?> readToken() => read(key: accessKey);

  Future<String?> readRefreshToken() => read(key: refreshKey);

  Future<void> clear() async {
    await delete(key: accessKey);
    await delete(key: refreshKey);
  }
}

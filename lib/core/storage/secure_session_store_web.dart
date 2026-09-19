/////
// secure_session_store_web.dart — Web/PWA implementation.
// Loaded when dart.library.html is available (flutter build web).
//
// Persists tokens to localStorage so a session survives closing the tab or
// refreshing the page: on the next launch `restore()` reads the stored
// refresh token and rotates it against /v1/auth/refresh. (The previous
// in-memory implementation dropped tokens on every reload, forcing users
// to sign in again after simply closing the app.)
//
// This file is loaded via conditional import from secure_session_store.dart,
// so it must be fully self-contained. It does NOT pull in
// flutter_secure_storage_web (incompatible with WASM); localStorage is the
// best available browser-store here — the native builds use Keychain/Keystore.
/////
library;

import 'dart:html' as html;

/// Contract for session token persistence (web localStorage implementation).
class SecureSessionStore {
  static const accessKey = 'adp_access_token';
  static const refreshKey = 'adp_refresh_token';

  String? _access;
  String? _refresh;
  bool _loaded = false;

  void _hydrateOnce() {
    if (_loaded) return;
    _loaded = true;
    try {
      _access = html.window.localStorage.getItem(accessKey);
      _refresh = html.window.localStorage.getItem(refreshKey);
    } catch (_) {
      // Storage disabled (e.g. private mode): fall back to memory-only.
    }
  }

  void _persist(String key, String? value) {
    try {
      if (value == null) {
        html.window.localStorage.removeItem(key);
      } else {
        html.window.localStorage.setItem(key, value);
      }
    } catch (_) {
      // Ignore quota/security errors — memory copy still holds the value.
    }
  }

  Future<void> write({required String key, required String? value}) async {
    _hydrateOnce();
    if (key == accessKey) {
      _access = value;
      _persist(accessKey, value);
    }
    if (key == refreshKey) {
      _refresh = value;
      _persist(refreshKey, value);
    }
  }

  Future<String?> read({required String key}) async {
    _hydrateOnce();
    if (key == accessKey) return _access;
    if (key == refreshKey) return _refresh;
    return null;
  }

  Future<void> delete({required String key}) async {
    if (key == accessKey) {
      _access = null;
      _persist(accessKey, null);
    }
    if (key == refreshKey) {
      _refresh = null;
      _persist(refreshKey, null);
    }
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

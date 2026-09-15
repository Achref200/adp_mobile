/////
// secure_session_store_stub.dart — Default in-memory implementation.
// Used by the analyzer's default context and unit tests; overridden by
// the platform-specific implementations via conditional import.
/////
library;

/// Base session token persistence: in-memory by default.
/// Native builds override it with iOS Keychain / Android Keystore.
class SecureSessionStoreStubBase {
  /// Shard keys.
  static const accessKey = 'adp_access_token';
  static const refreshKey = 'adp_refresh_token';

  String? _access;
  String? _refresh;

  /// Write a value for [key].
  Future<void> write({required String key, required String? value}) async {
    if (key == accessKey) _access = value;
    if (key == refreshKey) _refresh = value;
  }

  /// Read a value for [key].
  Future<String?> read({required String key}) async {
    if (key == accessKey) return _access;
    if (key == refreshKey) return _refresh;
    return null;
  }

  /// Delete a value for [key].
  Future<void> delete({required String key}) async {
    if (key == accessKey) _access = null;
    if (key == refreshKey) _refresh = null;
  }

  /// Persist both access and refresh tokens.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: accessKey, value: accessToken);
    await write(key: refreshKey, value: refreshToken);
  }

  /// Load the access token.
  Future<String?> readToken() => read(key: accessKey);

  /// Load the refresh token.
  Future<String?> readRefreshToken() => read(key: refreshKey);

  /// Wipe all stored tokens.
  Future<void> clear() async {
    await delete(key: accessKey);
    await delete(key: refreshKey);
  }
}

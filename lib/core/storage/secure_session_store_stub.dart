/////
// secure_session_store_stub.dart — Abstract interface.
// Imported by default; overridden by platform-specific implementations.
/////

/// Contract for session token persistence.
/// Implemented natively (iOS Keychain / Android Keystore) and
/// with an in-memory fallback for the web/PWA preview.
abstract class SecureSessionStore {
  /// Shard keys.
  static const accessKey = 'adp_access_token';
  static const refreshKey = 'adp_refresh_token';

  /// Write a value for [key].
  Future<void> write({required String key, required String? value});

  /// Read a value for [key].
  Future<String?> read({required String key});

  /// Delete a value for [key].
  Future<void> delete({required String key});

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

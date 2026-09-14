import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionStore {
  static const _key = 'adp_access_token';
  static const _refreshKey = 'adp_refresh_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);
  Future<String?> readToken() => _storage.read(key: _key);
  Future<void> saveSession(
      {required String accessToken, required String refreshToken}) async {
    await saveToken(accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);
  Future<void> clear() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _refreshKey);
  }
}

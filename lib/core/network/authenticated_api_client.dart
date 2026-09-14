import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/storage/secure_session_store.dart';
import 'package:dio/dio.dart';

/// Adds the current bearer token and retries once after a rotating refresh.
class AuthenticatedApiClient {
  AuthenticatedApiClient(this._api, this._store);
  final ApiClient _api;
  final SecureSessionStore _store;
  Future<Response<dynamic>> get(String path) =>
      _request((token) => _api.get(path, accessToken: token));
  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _request((token) => _api.post(path, data: data, accessToken: token));
  Future<Response<dynamic>> put(String path, {Object? data}) =>
      _request((token) => _api.put(path, data: data, accessToken: token));
  Future<Response<dynamic>> _request(
      Future<Response<dynamic>> Function(String token) request) async {
    final token = await _store.readToken();
    if (token == null) throw StateError('No active ADP session.');
    try {
      return await request(token);
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
      final refresh = await _store.readRefreshToken();
      if (refresh == null) {
        await _store.clear();
        rethrow;
      }
      try {
        final response = await _api
            .post('/v1/auth/refresh', data: {'refreshToken': refresh});
        final body = response.data as Map<String, dynamic>;
        final nextToken = body['accessToken'] as String;
        await _store.saveSession(
            accessToken: nextToken,
            refreshToken: body['refreshToken'] as String);
        return await request(nextToken);
      } catch (_) {
        await _store.clear();
        rethrow;
      }
    }
  }
}

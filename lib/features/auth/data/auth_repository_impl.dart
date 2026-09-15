import 'package:adp_mobile/core/network/api_client.dart';
import 'package:adp_mobile/core/storage/secure_session_store.dart';
import 'package:adp_mobile/features/auth/domain/auth_repository.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._store);
  final ApiClient _api;
  final SecureSessionStore _store;
  @override
  Future<AuthSession> login(
          {required String email, required String password}) =>
      _authenticate('/v1/auth/login', {'email': email, 'password': password});
  @override
  Future<AuthSession> register(
          {required String firstName,
          required String lastName,
          required String email,
          required String country,
          required String password}) async {
    final json = await _exchange('/v1/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
      'password': password
    });
    // Registration intentionally does NOT persist a session: the member
    // returns to the login screen and signs in with their new credentials.
    return _sessionFromJson(json, isNewRegistration: true);
  }

  @override
  Future<AuthSession> googleSignIn({required String idToken}) async {
    final json = await _exchange('/v1/auth/google', {'idToken': idToken});
    final session = _sessionFromJson(json);
    await _store.saveSession(
        accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session;
  }

  Future<Map<String, dynamic>> _exchange(
      String path, Map<String, String> data) async {
    final response = await _api.post(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  AuthSession _sessionFromJson(Map<String, dynamic> json,
      {bool isNewRegistration = false}) {
    final user = _userFromJson(json['user'] as Map<String, dynamic>);
    return AuthSession(
        user: user,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        isNewRegistration: isNewRegistration);
  }

  Future<AuthSession> _authenticate(
      String path, Map<String, String> data) async {
    final json = await _exchange(path, data);
    final session = _sessionFromJson(json);
    await _store.saveSession(
        accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session;
  }

  @override
  Future<AuthSession?> restore() async {
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _api
          .post('/v1/auth/refresh', data: {'refreshToken': refreshToken});
      final json = response.data as Map<String, dynamic>;
      final accessToken = json['accessToken'] as String;
      final nextRefresh = json['refreshToken'] as String;
      final userResponse = await _api.get('/v1/me', accessToken: accessToken);
      final session = AuthSession(
          user: _userFromJson(userResponse.data as Map<String, dynamic>),
          accessToken: accessToken,
          refreshToken: nextRefresh);
      await _store.saveSession(
          accessToken: session.accessToken, refreshToken: session.refreshToken);
      return session;
    } catch (_) {
      await _store.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => _store.clear();
  User _userFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      directoryVisible: json['directoryVisible'] as bool? ?? false);
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._store);
  final SecureSessionStore _store;
  @override
  Future<AuthSession> login(
          {required String email, required String password}) =>
      _session(email: email);
  @override
  Future<AuthSession> register(
          {required String firstName,
          required String lastName,
          required String email,
          required String country,
          required String password}) async {
    // Mirrors the API contract: account created, then deliberate first login.
    return AuthSession(
        user: User(
            id: 'usr_001',
            firstName: firstName,
            lastName: lastName,
            email: email,
            country: country),
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        isNewRegistration: true);
  }

  @override
  Future<AuthSession> googleSignIn({required String idToken}) =>
      _session(email: 'amel@example.org');
  Future<AuthSession> _session(
      {required String email,
      String firstName = 'Amel',
      String lastName = 'Ben Salem',
      String country = 'France'}) async {
    final session = AuthSession(
        user: User(
            id: 'usr_001',
            firstName: firstName,
            lastName: lastName,
            email: email,
            country: country),
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token');
    await _store.saveSession(
        accessToken: session.accessToken, refreshToken: session.refreshToken);
    return session;
  }

  @override
  Future<AuthSession?> restore() async => await _store.readToken() == null
      ? null
      : _session(email: 'amel@example.org');
  @override
  Future<void> logout() => _store.clear();
}

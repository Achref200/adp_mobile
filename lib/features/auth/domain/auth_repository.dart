import 'package:adp_mobile/features/shared/domain/models.dart';

class AuthSession {
  const AuthSession(
      {required this.user,
      required this.accessToken,
      required this.refreshToken});
  final User user;
  final String accessToken;
  final String refreshToken;
}

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register(
      {required String firstName,
      required String lastName,
      required String email,
      required String country,
      required String password});
  Future<AuthSession?> restore();
  Future<void> logout();
}

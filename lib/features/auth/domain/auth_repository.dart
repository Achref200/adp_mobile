import 'package:adp_mobile/features/shared/domain/models.dart';

class AuthSession {
  const AuthSession(
      {required this.user,
      required this.accessToken,
      required this.refreshToken,
      this.isNewRegistration = false});
  final User user;
  final String accessToken;
  final String refreshToken;

  /// True right after [AuthRepository.register]. ADP does not open a session
  /// automatically: the member returns to the login screen and signs in.
  final bool isNewRegistration;
}

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register(
      {required String firstName,
      required String lastName,
      required String email,
      required String country,
      required String password});

  /// Exchanges a Google Identity Services idToken for an ADP session,
  /// provisioning the account on first sign-in.
  Future<AuthSession> googleSignIn({required String idToken});
  Future<AuthSession?> restore();
  Future<void> logout();
}

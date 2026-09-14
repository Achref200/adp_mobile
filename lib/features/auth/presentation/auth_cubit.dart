import 'package:adp_mobile/features/auth/domain/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

enum AuthStatus { unknown, unauthenticated, loading, authenticated, failure }

class AuthState extends Equatable {
  const AuthState(
      {this.status = AuthStatus.unknown, this.session, this.message});
  final AuthStatus status;
  final AuthSession? session;
  final String? message;
  @override
  List<Object?> get props => [status, session?.accessToken, message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());
  final AuthRepository _repository;
  Future<void> restore() async {
    emit(const AuthState(status: AuthStatus.loading));
    final session = await _repository.restore();
    emit(AuthState(
        status: session == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        session: session));
  }

  Future<void> login({required String email, required String password}) =>
      _run(() => _repository.login(email: email, password: password));
  Future<void> register(
          {required String firstName,
          required String lastName,
          required String email,
          required String country,
          required String password}) =>
      _run(() => _repository.register(
          firstName: firstName,
          lastName: lastName,
          email: email,
          country: country,
          password: password));
  Future<void> _run(Future<AuthSession> Function() task) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      emit(AuthState(status: AuthStatus.authenticated, session: await task()));
    } catch (error) {
      var message = 'Une erreur est survenue. Réessayez.';
      if (error is DioException &&
          (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout)) {
        message =
            'Le serveur ADP est indisponible. Vérifiez que le backend est démarré.';
      } else if (error is DioException && error.response?.data is Map) {
        final body = error.response!.data as Map;
        final apiError = body['error'];
        if (apiError is Map && apiError['message'] is String) {
          message = apiError['message'] as String;
        }
      }
      emit(AuthState(status: AuthStatus.failure, message: message));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}

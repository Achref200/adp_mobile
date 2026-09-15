import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EPassCubit extends Cubit<AsyncState<EPass>> {
  EPassCubit(this._repository) : super(const AsyncState());
  final EPassRepository _repository;

  Future<void> load() async {
    emit(const AsyncState(status: AsyncStatus.loading));
    try {
      emit(AsyncState(
          status: AsyncStatus.success, data: await _repository.currentEPass()));
    } on StateError {
      // No active session yet — the listener reloads once authenticated.
      emit(const AsyncState());
    } catch (_) {
      emit(const AsyncState(
          status: AsyncStatus.failure,
          message:
              'Aucun e-Pass disponible pour le moment. Une adhésion active '
              '(cotisation validée par l\'association) est requise pour '
              'délivrer votre pass officiel.'));
    }
  }

  /// Checks the current QR payload against the backend verifier
  /// (HMAC signature + live membership status). Returns null on network error.
  Future<EPassVerification?> verifyCurrentPass() async {
    final pass = state.data;
    if (pass == null) return null;
    try {
      return await _repository.verifyPass(pass.qrPayload);
    } catch (_) {
      return null;
    }
  }
}

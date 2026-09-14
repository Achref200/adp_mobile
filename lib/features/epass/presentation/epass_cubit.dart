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
    } catch (_) {
      emit(const AsyncState(
          status: AsyncStatus.failure,
          message:
              'Votre e-Pass est indisponible. Une adhésion active est requise.'));
    }
  }
}

import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboxCubit extends Cubit<AsyncState<List<AppNotification>>> {
  InboxCubit(this._repository) : super(const AsyncState());
  final NotificationRepository _repository;

  Future<void> load() async {
    emit(const AsyncState(status: AsyncStatus.loading));
    try {
      final messages = await _repository.listNotifications();
      emit(AsyncState(
        status: messages.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
        data: messages,
      ));
    } catch (_) {
      emit(const AsyncState(
        status: AsyncStatus.failure,
        message: 'Les notifications sont temporairement indisponibles.',
      ));
    }
  }
}

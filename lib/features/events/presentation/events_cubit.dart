import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsCubit extends Cubit<AsyncState<List<Event>>> {
  EventsCubit(this._repository) : super(const AsyncState());
  final EventRepository _repository;
  Future<void> load() async {
    emit(const AsyncState(status: AsyncStatus.loading));
    try {
      final items = await _repository.listEvents();
      emit(AsyncState(
          status: items.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
          data: items));
    } catch (_) {
      emit(const AsyncState(
          status: AsyncStatus.failure,
          message: 'Les événements ne sont pas disponibles.'));
    }
  }
}

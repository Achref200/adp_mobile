import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsCubit extends Cubit<AsyncState<List<News>>> {
  NewsCubit(this._repository) : super(const AsyncState());
  final NewsRepository _repository;
  Future<void> load() async {
    emit(const AsyncState(status: AsyncStatus.loading));
    try {
      final items = await _repository.listNews();
      emit(AsyncState(
          status: items.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
          data: items));
    } catch (_) {
      emit(const AsyncState(
          status: AsyncStatus.failure,
          message: 'Les actualités ne sont pas disponibles.'));
    }
  }
}

import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkingState extends AsyncState<List<NetworkingProfile>> {
  const NetworkingState(
      {super.status,
      super.data,
      super.message,
      this.directoryVisible = false,
      this.actionMessage});
  final bool directoryVisible;
  final String? actionMessage;
  @override
  List<Object?> get props => [...super.props, directoryVisible, actionMessage];
  NetworkingState copyWith(
          {AsyncStatus? status,
          List<NetworkingProfile>? data,
          String? message,
          bool? directoryVisible,
          String? actionMessage}) =>
      NetworkingState(
          status: status ?? this.status,
          data: data ?? this.data,
          message: message,
          directoryVisible: directoryVisible ?? this.directoryVisible,
          actionMessage: actionMessage);
}

class NetworkingCubit extends Cubit<NetworkingState> {
  NetworkingCubit(this._repository) : super(const NetworkingState());
  final NetworkingRepository _repository;
  Future<void> load() async {
    emit(state.copyWith(status: AsyncStatus.loading));
    try {
      final profiles = await _repository.directory();
      emit(state.copyWith(
          status: profiles.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
          data: profiles));
    } catch (_) {
      emit(state.copyWith(
          status: AsyncStatus.failure,
          message: 'L’annuaire est indisponible.'));
    }
  }

  Future<void> updateVisibility(bool visible) async {
    final before = state;
    emit(state.copyWith(directoryVisible: visible));
    try {
      await _repository.updateVisibility(visible);
      emit(state.copyWith(
          actionMessage: visible
              ? 'Votre profil est visible dans l’annuaire.'
              : 'Votre profil est maintenant privé.'));
    } catch (_) {
      emit(before.copyWith(
          message: 'Impossible de mettre à jour votre visibilité.'));
    }
  }

  Future<void> requestConnection(String recipientId) async {
    try {
      await _repository.requestConnection(recipientId);
      emit(state.copyWith(
          actionMessage: 'Demande de mise en relation envoyée.'));
    } catch (_) {
      emit(state.copyWith(message: 'Impossible d’envoyer la demande.'));
    }
  }
}

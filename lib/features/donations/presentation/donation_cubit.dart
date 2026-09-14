import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DonationState extends AsyncState<Uri> {
  const DonationState(
      {super.status, super.data, super.message, this.history = const []});
  final List<Donation> history;
  @override
  List<Object?> get props => [...super.props, history];
}

class DonationCubit extends Cubit<DonationState> {
  DonationCubit(this._repository) : super(const DonationState());
  final DonationRepository _repository;
  Future<void> loadHistory() async {
    emit(DonationState(status: AsyncStatus.loading, history: state.history));
    try {
      final history = await _repository.history();
      emit(DonationState(
          status: history.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
          history: history));
    } catch (_) {
      emit(DonationState(
          status: AsyncStatus.failure,
          message: 'Historique des dons indisponible.',
          history: state.history));
    }
  }

  Future<void> beginCheckout(
      {required int amountCents,
      required DonationFrequency frequency,
      required bool anonymous,
      String? projectId}) async {
    emit(DonationState(status: AsyncStatus.loading, history: state.history));
    try {
      final url = await _repository.createCheckoutUrl(
          amountCents: amountCents,
          frequency: frequency,
          anonymous: anonymous,
          projectId: projectId);
      emit(DonationState(
          status: AsyncStatus.success, data: url, history: state.history));
    } catch (_) {
      emit(DonationState(
          status: AsyncStatus.failure,
          message: 'Le paiement est momentanément indisponible.',
          history: state.history));
    }
  }

  void clearCheckout() => emit(DonationState(
      status: state.history.isEmpty ? AsyncStatus.empty : AsyncStatus.success,
      history: state.history));
}

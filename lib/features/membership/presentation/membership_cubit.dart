import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MembershipState extends AsyncState<Membership> {
  const MembershipState(
      {super.status, super.data, super.message, this.checkoutUrl});
  final Uri? checkoutUrl;
  @override
  List<Object?> get props => [...super.props, checkoutUrl];
}

class MembershipCubit extends Cubit<MembershipState> {
  MembershipCubit(this._repository) : super(const MembershipState());
  final MembershipRepository _repository;
  Future<void> load() async {
    emit(const MembershipState(status: AsyncStatus.loading));
    try {
      emit(MembershipState(
          status: AsyncStatus.success,
          data: await _repository.currentMembership()));
    } catch (_) {
      emit(const MembershipState(
          status: AsyncStatus.failure,
          message: 'Le statut d’adhésion est indisponible.'));
    }
  }

  Future<void> submit(MembershipSubmission input) async {
    emit(const MembershipState(status: AsyncStatus.loading));
    try {
      emit(MembershipState(
          status: AsyncStatus.success, data: await _repository.submit(input)));
    } catch (_) {
      emit(const MembershipState(
          status: AsyncStatus.failure,
          message: 'Impossible d’envoyer la demande.'));
    }
  }

  Future<void> beginCheckout() async {
    final membership = state.data;
    if (membership == null) return;
    emit(MembershipState(status: AsyncStatus.loading, data: membership));
    try {
      emit(MembershipState(
          status: AsyncStatus.success,
          data: membership,
          checkoutUrl:
              await _repository.createMembershipCheckoutUrl(membership.id)));
    } catch (_) {
      emit(MembershipState(
          status: AsyncStatus.failure,
          data: membership,
          message: 'Le paiement est momentanément indisponible.'));
    }
  }

  void clearCheckout() =>
      emit(MembershipState(status: AsyncStatus.success, data: state.data));
}

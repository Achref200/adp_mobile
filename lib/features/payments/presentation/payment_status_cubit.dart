import 'package:adp_mobile/core/state/async_state.dart';
import 'package:adp_mobile/features/shared/domain/models.dart';
import 'package:adp_mobile/features/shared/domain/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentStatusCubit extends Cubit<AsyncState<CheckoutVerification>> {
  PaymentStatusCubit(this._repository) : super(const AsyncState());
  final PaymentStatusRepository _repository;

  Future<void> verify(String checkoutIntentId) async {
    emit(const AsyncState(status: AsyncStatus.loading));
    try {
      emit(AsyncState(status: AsyncStatus.success, data: await _repository.verifyCheckout(checkoutIntentId)));
    } catch (_) {
      emit(const AsyncState(status: AsyncStatus.failure, message: 'Le paiement ne peut pas encore être vérifié.'));
    }
  }
}

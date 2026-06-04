import '../entities/confirm_order_payment_input.dart';
import '../repositories/orders_repository.dart';

class ConfirmOrderPayment {
  const ConfirmOrderPayment(this._repository);

  final OrdersRepository _repository;

  Future<void> call(ConfirmOrderPaymentInput input) {
    return _repository.confirmPayment(input);
  }
}

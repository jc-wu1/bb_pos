import '../repositories/orders_repository.dart';

class CancelOrder {
  const CancelOrder(this._repository);

  final OrdersRepository _repository;

  Future<void> call(int orderId) {
    return _repository.cancelOrder(orderId);
  }
}

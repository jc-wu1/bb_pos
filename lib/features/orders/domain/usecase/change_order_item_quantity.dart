import '../entities/order_item_quantity_input.dart';
import '../repositories/orders_repository.dart';

class ChangeOrderItemQuantity {
  const ChangeOrderItemQuantity(this._repository);

  final OrdersRepository _repository;

  Future<void> call(OrderItemQuantityInput input) {
    return _repository.changeItemQuantity(input);
  }
}

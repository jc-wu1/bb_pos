import '../entities/set_order_item_quantity_input.dart';
import '../repositories/orders_repository.dart';

class SetOrderItemQuantity {
  const SetOrderItemQuantity(this._repository);

  final OrdersRepository _repository;

  Future<void> call(SetOrderItemQuantityInput input) {
    return _repository.setItemQuantity(input);
  }
}

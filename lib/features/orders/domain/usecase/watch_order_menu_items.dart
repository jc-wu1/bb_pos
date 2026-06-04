import '../entities/order_menu_item_entity.dart';
import '../repositories/orders_repository.dart';

class WatchOrderMenuItems {
  const WatchOrderMenuItems(this._repository);

  final OrdersRepository _repository;

  Stream<List<OrderMenuItemEntity>> call() {
    return _repository.watchMenuItems();
  }
}

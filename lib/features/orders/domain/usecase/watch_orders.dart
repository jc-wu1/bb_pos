import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class WatchOrders {
  const WatchOrders(this._repository);

  final OrdersRepository _repository;

  Stream<List<OrderEntity>> call() {
    return _repository.watchOpenOrders();
  }
}

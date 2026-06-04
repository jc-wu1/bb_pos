import '../../domain/entities/confirm_order_payment_input.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_quantity_input.dart';
import '../../domain/entities/order_menu_item_entity.dart';
import '../../domain/entities/set_order_item_quantity_input.dart';
import '../../domain/repositories/orders_repository.dart';
import '../data_sources/orders_local_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl({required OrdersLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final OrdersLocalDataSource _localDataSource;

  @override
  Stream<List<OrderEntity>> watchOpenOrders() {
    return _localDataSource.watchOpenOrders();
  }

  @override
  Stream<List<OrderMenuItemEntity>> watchMenuItems() {
    return _localDataSource.watchMenuItems();
  }

  @override
  Future<int> createOrder() {
    return _localDataSource.createOrder();
  }

  @override
  Future<void> changeItemQuantity(OrderItemQuantityInput input) {
    return _localDataSource.changeItemQuantity(input);
  }

  @override
  Future<void> setItemQuantity(SetOrderItemQuantityInput input) {
    return _localDataSource.setItemQuantity(input);
  }

  @override
  Future<void> cancelOrder(int orderId) {
    return _localDataSource.cancelOrder(orderId);
  }

  @override
  Future<void> confirmPayment(ConfirmOrderPaymentInput input) {
    return _localDataSource.confirmPayment(input);
  }
}

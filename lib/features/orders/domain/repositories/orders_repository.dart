import '../entities/confirm_order_payment_input.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_quantity_input.dart';
import '../entities/order_menu_item_entity.dart';
import '../entities/set_order_item_quantity_input.dart';

abstract interface class OrdersRepository {
  Stream<List<OrderEntity>> watchOpenOrders();

  Stream<List<OrderMenuItemEntity>> watchMenuItems();

  Future<int> createOrder();

  Future<void> changeItemQuantity(OrderItemQuantityInput input);

  Future<void> setItemQuantity(SetOrderItemQuantityInput input);

  Future<void> cancelOrder(int orderId);

  Future<void> confirmPayment(ConfirmOrderPaymentInput input);
}

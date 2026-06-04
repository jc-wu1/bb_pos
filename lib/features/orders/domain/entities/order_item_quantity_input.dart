import 'order_line_entity.dart';
import 'order_menu_item_entity.dart';

class OrderItemQuantityInput {
  const OrderItemQuantityInput({
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemPrice,
    required this.delta,
  });

  factory OrderItemQuantityInput.fromMenuItem({
    required int orderId,
    required OrderMenuItemEntity item,
    required int delta,
  }) {
    return OrderItemQuantityInput(
      orderId: orderId,
      menuItemId: item.id,
      menuItemName: item.name,
      menuItemPrice: item.price,
      delta: delta,
    );
  }

  factory OrderItemQuantityInput.fromOrderLine({
    required OrderLineEntity line,
    required int delta,
  }) {
    return OrderItemQuantityInput(
      orderId: line.orderId,
      menuItemId: line.menuItemId,
      menuItemName: line.menuItemName,
      menuItemPrice: line.menuItemPrice,
      delta: delta,
    );
  }

  final int orderId;
  final int menuItemId;
  final String menuItemName;
  final int menuItemPrice;
  final int delta;
}

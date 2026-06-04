import '../../../../core/database/database.dart' as db;
import '../../domain/entities/order_line_entity.dart';

class OrderLineModel extends OrderLineEntity {
  const OrderLineModel({
    required super.id,
    required super.orderId,
    required super.menuItemId,
    required super.menuItemName,
    required super.menuItemPrice,
    required super.quantity,
    required super.notes,
    required super.subtotal,
  });

  factory OrderLineModel.fromDatabase(db.OrderItem item) {
    return OrderLineModel(
      id: item.id,
      orderId: item.orderId,
      menuItemId: item.menuItemId,
      menuItemName: item.menuItemName,
      menuItemPrice: item.menuItemPrice,
      quantity: item.quantity,
      notes: item.notes,
      subtotal: item.subtotal,
    );
  }
}

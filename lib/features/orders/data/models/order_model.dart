import '../../../../core/database/database.dart' as db;
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import 'order_line_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.orderType,
    required super.customerName,
    required super.status,
    required super.notes,
    required super.totalAmount,
    required super.createdAt,
    required super.updatedAt,
    required super.items,
  });

  factory OrderModel.fromDatabase({
    required db.Order order,
    required List<OrderLineModel> items,
  }) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      orderType: OrderType.fromDatabaseValue(order.orderType),
      customerName: order.customerName,
      status: OrderStatus.fromDatabaseValue(order.status),
      notes: order.notes,
      totalAmount: order.totalAmount,
      createdAt: DateTime.parse(order.createdAt),
      updatedAt: DateTime.parse(order.updatedAt),
      items: List.unmodifiable(items),
    );
  }
}

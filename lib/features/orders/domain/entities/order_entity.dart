import 'package:equatable/equatable.dart';

import 'order_line_entity.dart';
import 'order_status.dart';
import 'order_type.dart';

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.customerName,
    required this.status,
    required this.notes,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final OrderType orderType;
  final String? customerName;
  final OrderStatus status;
  final String? notes;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderLineEntity> items;

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  String get customerLabel {
    final value = customerName?.trim();
    return value == null || value.isEmpty ? 'Order Baru' : value;
  }

  @override
  List<Object?> get props {
    return [
      id,
      orderNumber,
      orderType,
      customerName,
      status,
      notes,
      totalAmount,
      createdAt,
      updatedAt,
      items,
    ];
  }
}

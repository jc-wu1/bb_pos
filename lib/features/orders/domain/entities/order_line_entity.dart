import 'package:equatable/equatable.dart';

class OrderLineEntity extends Equatable {
  const OrderLineEntity({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemPrice,
    required this.quantity,
    required this.notes,
    required this.subtotal,
  });

  final int id;
  final int orderId;
  final int menuItemId;
  final String menuItemName;
  final int menuItemPrice;
  final int quantity;
  final String? notes;
  final int subtotal;

  @override
  List<Object?> get props {
    return [
      id,
      orderId,
      menuItemId,
      menuItemName,
      menuItemPrice,
      quantity,
      notes,
      subtotal,
    ];
  }
}

class SetOrderItemQuantityInput {
  const SetOrderItemQuantityInput({
    required this.orderId,
    required this.orderItemId,
    required this.quantity,
  });

  final int orderId;
  final int orderItemId;
  final int quantity;
}

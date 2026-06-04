enum OrderStatus {
  open,
  completed,
  canceled;

  String get databaseValue {
    return switch (this) {
      OrderStatus.open => 'open',
      OrderStatus.completed => 'completed',
      OrderStatus.canceled => 'canceled',
    };
  }

  static OrderStatus fromDatabaseValue(String value) {
    return switch (value) {
      'open' => OrderStatus.open,
      'completed' => OrderStatus.completed,
      'canceled' => OrderStatus.canceled,
      _ => throw ArgumentError.value(value, 'value', 'Unknown order status.'),
    };
  }
}

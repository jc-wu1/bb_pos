enum OrderPaymentMethod {
  cash,
  qris;

  String get databaseValue {
    return switch (this) {
      OrderPaymentMethod.cash => 'cash',
      OrderPaymentMethod.qris => 'qris',
    };
  }

  String get label {
    return switch (this) {
      OrderPaymentMethod.cash => 'Cash',
      OrderPaymentMethod.qris => 'QRIS',
    };
  }

  static OrderPaymentMethod fromDatabaseValue(String value) {
    return switch (value) {
      'cash' => OrderPaymentMethod.cash,
      'qris' => OrderPaymentMethod.qris,
      _ => throw ArgumentError.value(value, 'value', 'Unknown payment method.'),
    };
  }
}

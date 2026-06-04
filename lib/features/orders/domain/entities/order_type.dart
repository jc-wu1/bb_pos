enum OrderType {
  dineIn,
  takeAway;

  String get databaseValue {
    return switch (this) {
      OrderType.dineIn => 'dine_in',
      OrderType.takeAway => 'take_away',
    };
  }

  static OrderType fromDatabaseValue(String value) {
    return switch (value) {
      'dine_in' => OrderType.dineIn,
      'take_away' => OrderType.takeAway,
      _ => throw ArgumentError.value(value, 'value', 'Unknown order type.'),
    };
  }
}

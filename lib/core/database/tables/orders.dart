import 'package:drift/drift.dart';

class Orders extends Table {
  @override
  String get tableName => 'orders';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text().named('order_number').unique()();
  TextColumn get orderType => text()
      .named('order_type')
      .customConstraint(
        "NOT NULL CHECK (order_type IN ('dine_in', 'take_away'))",
      )();
  TextColumn get customerName => text().named('customer_name').nullable()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('open', 'completed', 'canceled'))",
  )();
  TextColumn get notes => text().nullable()();
  IntColumn get totalAmount => integer().named('total_amount')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
}

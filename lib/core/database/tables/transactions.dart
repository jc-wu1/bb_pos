import 'package:drift/drift.dart';

import 'orders.dart';

class Transactions extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().named('order_id').unique().references(Orders, #id)();
  TextColumn get paymentMethod => text()
      .named('payment_method')
      .customConstraint(
        "NOT NULL CHECK (payment_method IN ('cash', 'qris'))",
      )();
  IntColumn get totalAmount => integer().named('total_amount')();
  IntColumn get amountPaid => integer().named('amount_paid').nullable()();
  IntColumn get changeAmount => integer().named('change_amount').nullable()();
  TextColumn get paidAt => text().named('paid_at')();
}

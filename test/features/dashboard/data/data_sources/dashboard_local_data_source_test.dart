import 'package:bb_pos/core/database/database.dart';
import 'package:bb_pos/features/dashboard/data/data_sources/dashboard_local_data_source.dart';
import 'package:bb_pos/features/orders/domain/entities/order_payment_method.dart';
import 'package:bb_pos/features/orders/domain/entities/order_status.dart';
import 'package:bb_pos/features/orders/domain/entities/order_type.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftDashboardLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = DriftDashboardLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('summarizes today total amount by payment method', () async {
    await _insertMenuItem(database);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final cashOrderId = await _insertCompletedOrder(
      database,
      orderNumber: 'BLP-CASH',
      totalAmount: 20000,
      paidAt: now,
    );
    final qrisOrderId = await _insertCompletedOrder(
      database,
      orderNumber: 'BLP-QRIS',
      totalAmount: 50000,
      paidAt: now,
    );
    final yesterdayOrderId = await _insertCompletedOrder(
      database,
      orderNumber: 'BLP-YESTERDAY',
      totalAmount: 90000,
      paidAt: yesterday,
    );

    await _insertTransaction(
      database,
      orderId: cashOrderId,
      method: OrderPaymentMethod.cash,
      totalAmount: 20000,
      amountPaid: 50000,
      changeAmount: 30000,
      paidAt: now,
    );
    await _insertTransaction(
      database,
      orderId: qrisOrderId,
      method: OrderPaymentMethod.qris,
      totalAmount: 50000,
      amountPaid: 50000,
      changeAmount: 0,
      paidAt: now,
    );
    await _insertTransaction(
      database,
      orderId: yesterdayOrderId,
      method: OrderPaymentMethod.cash,
      totalAmount: 90000,
      amountPaid: 90000,
      changeAmount: 0,
      paidAt: yesterday,
    );

    final snapshot = await dataSource.watchDashboard().first;
    final cashTotal = snapshot.paymentMethodTotals.singleWhere(
      (item) => item.method == OrderPaymentMethod.cash,
    );
    final qrisTotal = snapshot.paymentMethodTotals.singleWhere(
      (item) => item.method == OrderPaymentMethod.qris,
    );

    expect(
      snapshot.paymentMethodTotals.length,
      OrderPaymentMethod.values.length,
    );
    expect(cashTotal.totalAmount, 20000);
    expect(cashTotal.transactionCount, 1);
    expect(cashTotal.share, closeTo(20000 / 70000, 0.001));
    expect(qrisTotal.totalAmount, 50000);
    expect(qrisTotal.transactionCount, 1);
    expect(qrisTotal.share, closeTo(50000 / 70000, 0.001));
  });
}

Future<int> _insertMenuItem(AppDatabase database) async {
  final now = DateTime.now().toIso8601String();
  final category = await (database.select(
    database.categories,
  )..where((row) => row.name.equals('Makanan'))).getSingle();

  return database
      .into(database.menuItems)
      .insert(
        MenuItemsCompanion.insert(
          categoryId: category.id,
          name: 'Bakmi Ayam',
          price: 20000,
          displayOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<int> _insertCompletedOrder(
  AppDatabase database, {
  required String orderNumber,
  required int totalAmount,
  required DateTime paidAt,
}) {
  final paidAtIso = paidAt.toIso8601String();

  return database
      .into(database.orders)
      .insert(
        OrdersCompanion.insert(
          orderNumber: orderNumber,
          orderType: OrderType.dineIn.databaseValue,
          customerName: const Value('Customer'),
          status: OrderStatus.completed.databaseValue,
          totalAmount: totalAmount,
          createdAt: paidAtIso,
          updatedAt: paidAtIso,
        ),
      );
}

Future<int> _insertTransaction(
  AppDatabase database, {
  required int orderId,
  required OrderPaymentMethod method,
  required int totalAmount,
  required int amountPaid,
  required int changeAmount,
  required DateTime paidAt,
}) {
  return database
      .into(database.transactions)
      .insert(
        TransactionsCompanion.insert(
          orderId: orderId,
          paymentMethod: method.databaseValue,
          totalAmount: totalAmount,
          amountPaid: Value(amountPaid),
          changeAmount: Value(changeAmount),
          paidAt: paidAt.toIso8601String(),
        ),
      );
}

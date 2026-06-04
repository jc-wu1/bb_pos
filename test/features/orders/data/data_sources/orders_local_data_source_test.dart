import 'package:bb_pos/core/database/database.dart';
import 'package:bb_pos/features/orders/data/data_sources/orders_local_data_source.dart';
import 'package:bb_pos/features/orders/domain/entities/confirm_order_payment_input.dart';
import 'package:bb_pos/features/orders/domain/entities/order_item_quantity_input.dart';
import 'package:bb_pos/features/orders/domain/entities/order_payment_method.dart';
import 'package:bb_pos/features/orders/domain/entities/order_status.dart';
import 'package:bb_pos/features/orders/domain/entities/order_type.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftOrdersLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = DriftOrdersLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates daily BLP orders and counts canceled customers', () async {
    final todayPrefix = _todayOrderPrefix();
    final firstOrderId = await dataSource.createOrder();
    final firstOrder = await _findOrder(database, firstOrderId);

    expect(firstOrder.orderNumber, '${todayPrefix}01');
    expect(firstOrder.customerName, 'Customer #1');

    await dataSource.cancelOrder(firstOrderId);

    final secondOrderId = await dataSource.createOrder();
    final secondOrder = await _findOrder(database, secondOrderId);

    expect(secondOrder.orderNumber, '${todayPrefix}02');
    expect(secondOrder.customerName, 'Customer #2');
    expect(
      (await _findOrder(database, firstOrderId)).status,
      OrderStatus.canceled.databaseValue,
    );
  });

  test('watches only today open orders', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await database
        .into(database.orders)
        .insert(
          OrdersCompanion.insert(
            orderNumber: 'BLP2000010101',
            orderType: OrderType.dineIn.databaseValue,
            customerName: const Value('Customer #1'),
            status: OrderStatus.open.databaseValue,
            totalAmount: 0,
            createdAt: yesterday.toIso8601String(),
            updatedAt: yesterday.toIso8601String(),
          ),
        );
    final canceledOrderId = await dataSource.createOrder();
    await dataSource.cancelOrder(canceledOrderId);
    final todayOrderId = await dataSource.createOrder();

    final orders = await dataSource.watchOpenOrders().first;

    expect(orders.map((order) => order.id), [todayOrderId]);
    expect(orders.map((order) => order.status), [OrderStatus.open]);
  });

  test(
    'stores amount paid and change amount when confirming payment',
    () async {
      final menuItemId = await _insertMenuItem(database);
      final orderId = await dataSource.createOrder();
      await dataSource.changeItemQuantity(
        OrderItemQuantityInput(
          orderId: orderId,
          menuItemId: menuItemId,
          menuItemName: 'Bakmi Ayam',
          menuItemPrice: 20000,
          delta: 1,
        ),
      );

      await dataSource.confirmPayment(
        ConfirmOrderPaymentInput(
          orderId: orderId,
          paymentMethod: OrderPaymentMethod.cash,
          amountPaid: 50000,
          changeAmount: 30000,
        ),
      );

      final transaction = await (database.select(
        database.transactions,
      )..where((row) => row.orderId.equals(orderId))).getSingle();

      expect(transaction.paymentMethod, OrderPaymentMethod.cash.databaseValue);
      expect(transaction.totalAmount, 20000);
      expect(transaction.amountPaid, 50000);
      expect(transaction.changeAmount, 30000);
    },
  );
}

Future<Order> _findOrder(AppDatabase database, int orderId) {
  final query = database.select(database.orders)
    ..where((order) => order.id.equals(orderId));

  return query.getSingle();
}

String _todayOrderPrefix() {
  final now = DateTime.now();

  return 'BLP'
      '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';
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

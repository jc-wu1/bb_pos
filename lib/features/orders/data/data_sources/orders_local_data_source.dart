import 'package:drift/drift.dart';

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/confirm_order_payment_input.dart';
import '../../domain/entities/order_item_quantity_input.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/entities/set_order_item_quantity_input.dart';
import '../models/order_line_model.dart';
import '../models/order_menu_item_model.dart';
import '../models/order_model.dart';

abstract interface class OrdersLocalDataSource {
  Stream<List<OrderModel>> watchOpenOrders();

  Stream<List<OrderMenuItemModel>> watchMenuItems();

  Future<int> createOrder();

  Future<void> changeItemQuantity(OrderItemQuantityInput input);

  Future<void> setItemQuantity(SetOrderItemQuantityInput input);

  Future<void> cancelOrder(int orderId);

  Future<void> confirmPayment(ConfirmOrderPaymentInput input);
}

class DriftOrdersLocalDataSource implements OrdersLocalDataSource {
  const DriftOrdersLocalDataSource(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<OrderModel>> watchOpenOrders() {
    final orderTable = _database.orders;
    final itemTable = _database.orderItems;
    final todayRange = _dateRangeFor(DateTime.now());
    final query =
        (_database.select(orderTable)..where(
              (order) =>
                  order.status.equals(OrderStatus.open.databaseValue) &
                  order.createdAt.isBiggerOrEqualValue(todayRange.startIso) &
                  order.createdAt.isSmallerThanValue(todayRange.endIso),
            ))
            .join([
              leftOuterJoin(
                itemTable,
                itemTable.orderId.equalsExp(orderTable.id),
              ),
            ])
          ..orderBy([
            OrderingTerm(
              expression: orderTable.createdAt,
              mode: OrderingMode.desc,
            ),
            OrderingTerm(expression: itemTable.id),
          ]);

    return query.watch().map(_mapOrderRows);
  }

  @override
  Stream<List<OrderMenuItemModel>> watchMenuItems() {
    final query =
        _database.select(_database.menuItems).join([
          innerJoin(
            _database.categories,
            _database.categories.id.equalsExp(_database.menuItems.categoryId),
          ),
        ])..orderBy([
          OrderingTerm(expression: _database.categories.displayOrder),
          OrderingTerm(expression: _database.menuItems.displayOrder),
          OrderingTerm(expression: _database.menuItems.name),
        ]);

    return query.watch().map((rows) {
      return List.unmodifiable(
        rows.map((row) {
          return OrderMenuItemModel.fromDatabase(
            item: row.readTable(_database.menuItems),
            category: row.readTable(_database.categories),
          );
        }),
      );
    });
  }

  @override
  Future<int> createOrder() {
    return _database.transaction(() async {
      final now = DateTime.now();
      final dailySequence = await _nextOrderSequenceFor(now);
      final orderNumber = _orderNumberFor(now, dailySequence);

      return _database
          .into(_database.orders)
          .insert(
            db.OrdersCompanion.insert(
              orderNumber: orderNumber,
              orderType: OrderType.dineIn.databaseValue,
              customerName: Value('Customer #$dailySequence'),
              status: OrderStatus.open.databaseValue,
              totalAmount: 0,
              createdAt: now.toIso8601String(),
              updatedAt: now.toIso8601String(),
            ),
          );
    });
  }

  @override
  Future<void> changeItemQuantity(OrderItemQuantityInput input) async {
    if (input.delta == 0) return;

    await _database.transaction(() async {
      await _ensureOpenOrder(input.orderId);

      final existingLine = await _findOrderLine(
        orderId: input.orderId,
        menuItemId: input.menuItemId,
      );

      if (existingLine == null) {
        if (input.delta <= 0) return;

        await _database
            .into(_database.orderItems)
            .insert(
              db.OrderItemsCompanion.insert(
                orderId: input.orderId,
                menuItemId: input.menuItemId,
                menuItemName: input.menuItemName,
                menuItemPrice: input.menuItemPrice,
                quantity: input.delta,
                subtotal: input.menuItemPrice * input.delta,
              ),
            );
        await _refreshOrderTotal(input.orderId);
        return;
      }

      final nextQuantity = existingLine.quantity + input.delta;
      if (nextQuantity <= 0) {
        await (_database.delete(
          _database.orderItems,
        )..where((line) => line.id.equals(existingLine.id))).go();
        await _refreshOrderTotal(input.orderId);
        return;
      }

      await (_database.update(
        _database.orderItems,
      )..where((line) => line.id.equals(existingLine.id))).write(
        db.OrderItemsCompanion(
          quantity: Value(nextQuantity),
          subtotal: Value(existingLine.menuItemPrice * nextQuantity),
        ),
      );
      await _refreshOrderTotal(input.orderId);
    });
  }

  @override
  Future<void> setItemQuantity(SetOrderItemQuantityInput input) async {
    await _database.transaction(() async {
      await _ensureOpenOrder(input.orderId);
      final existingLine = await _findOrderLineById(
        orderId: input.orderId,
        orderItemId: input.orderItemId,
      );
      if (existingLine == null) {
        throw StateError('Order item ${input.orderItemId} was not found.');
      }

      if (input.quantity <= 0) {
        await (_database.delete(
          _database.orderItems,
        )..where((line) => line.id.equals(existingLine.id))).go();
        await _refreshOrderTotal(input.orderId);
        return;
      }

      await (_database.update(
        _database.orderItems,
      )..where((line) => line.id.equals(existingLine.id))).write(
        db.OrderItemsCompanion(
          quantity: Value(input.quantity),
          subtotal: Value(existingLine.menuItemPrice * input.quantity),
        ),
      );
      await _refreshOrderTotal(input.orderId);
    });
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    await _database.transaction(() async {
      await _ensureOpenOrder(orderId);
      await (_database.update(
        _database.orders,
      )..where((order) => order.id.equals(orderId))).write(
        db.OrdersCompanion(
          status: Value(OrderStatus.canceled.databaseValue),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    });
  }

  @override
  Future<void> confirmPayment(ConfirmOrderPaymentInput input) async {
    await _database.transaction(() async {
      await _ensureOpenOrder(input.orderId);

      final lines = await (_database.select(
        _database.orderItems,
      )..where((line) => line.orderId.equals(input.orderId))).get();
      if (lines.isEmpty) {
        throw StateError('Order ${input.orderId} has no items.');
      }

      final now = DateTime.now().toIso8601String();
      final total = lines.fold<int>(0, (sum, line) => sum + line.subtotal);

      await _database
          .into(_database.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              orderId: input.orderId,
              paymentMethod: input.paymentMethod.databaseValue,
              totalAmount: total,
              amountPaid: Value(input.amountPaid),
              changeAmount: Value(input.changeAmount),
              paidAt: now,
            ),
          );

      await (_database.update(
        _database.orders,
      )..where((order) => order.id.equals(input.orderId))).write(
        db.OrdersCompanion(
          status: Value(OrderStatus.completed.databaseValue),
          totalAmount: Value(total),
          updatedAt: Value(now),
        ),
      );
    });
  }

  List<OrderModel> _mapOrderRows(List<TypedResult> rows) {
    final groupedRows = <int, _OrderRowGroup>{};

    for (final row in rows) {
      final order = row.readTable(_database.orders);
      final group = groupedRows.putIfAbsent(
        order.id,
        () => _OrderRowGroup(order),
      );
      final line = row.readTableOrNull(_database.orderItems);
      if (line != null) {
        group.lines.add(OrderLineModel.fromDatabase(line));
      }
    }

    return List.unmodifiable(
      groupedRows.values.map((group) {
        return OrderModel.fromDatabase(
          order: group.order,
          items: List.unmodifiable(group.lines),
        );
      }),
    );
  }

  Future<int> _nextOrderSequenceFor(DateTime date) async {
    final range = _dateRangeFor(date);
    final countExpression = _database.orders.id.count();
    final query = _database.selectOnly(_database.orders)
      ..addColumns([countExpression])
      ..where(
        _database.orders.createdAt.isBiggerOrEqualValue(range.startIso) &
            _database.orders.createdAt.isSmallerThanValue(range.endIso),
      );
    final row = await query.getSingle();

    return (row.read(countExpression) ?? 0) + 1;
  }

  String _orderNumberFor(DateTime date, int sequence) {
    return 'BLP'
        '${date.year}'
        '${_twoDigits(date.month)}'
        '${_twoDigits(date.day)}'
        '${sequence.toString().padLeft(2, '0')}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  _DateRange _dateRangeFor(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _DateRange(
      startIso: start.toIso8601String(),
      endIso: end.toIso8601String(),
    );
  }

  Future<void> _ensureOpenOrder(int orderId) async {
    final query = _database.select(_database.orders)
      ..where(
        (order) =>
            order.id.equals(orderId) &
            order.status.equals(OrderStatus.open.databaseValue),
      )
      ..limit(1);

    final order = await query.getSingleOrNull();
    if (order == null) {
      throw StateError('Open order $orderId was not found.');
    }
  }

  Future<db.OrderItem?> _findOrderLine({
    required int orderId,
    required int menuItemId,
  }) {
    final query = _database.select(_database.orderItems)
      ..where(
        (line) =>
            line.orderId.equals(orderId) & line.menuItemId.equals(menuItemId),
      )
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<db.OrderItem?> _findOrderLineById({
    required int orderId,
    required int orderItemId,
  }) {
    final query = _database.select(_database.orderItems)
      ..where(
        (line) => line.orderId.equals(orderId) & line.id.equals(orderItemId),
      )
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<void> _refreshOrderTotal(int orderId) async {
    final linesQuery = _database.select(_database.orderItems)
      ..where((line) => line.orderId.equals(orderId));
    final lines = await linesQuery.get();
    final total = lines.fold<int>(0, (sum, line) => sum + line.subtotal);

    await (_database.update(
      _database.orders,
    )..where((order) => order.id.equals(orderId))).write(
      db.OrdersCompanion(
        totalAmount: Value(total),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }
}

class _OrderRowGroup {
  _OrderRowGroup(this.order);

  final db.Order order;
  final List<OrderLineModel> lines = [];
}

class _DateRange {
  const _DateRange({required this.startIso, required this.endIso});

  final String startIso;
  final String endIso;
}

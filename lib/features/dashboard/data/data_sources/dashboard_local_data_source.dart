import 'package:drift/drift.dart';

import '../../../../core/database/database.dart' as db;
import '../../../orders/domain/entities/order_payment_method.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../domain/entities/dashboard_snapshot.dart';

abstract interface class DashboardLocalDataSource {
  Stream<DashboardSnapshot> watchDashboard();
}

class DriftDashboardLocalDataSource implements DashboardLocalDataSource {
  const DriftDashboardLocalDataSource(this._database);

  static const int _listLimit = 5;

  final db.AppDatabase _database;

  @override
  Stream<DashboardSnapshot> watchDashboard() {
    return _database
        .customSelect(
          'SELECT 1 AS changed',
          readsFrom: {
            _database.categories,
            _database.menuItems,
            _database.orderItems,
            _database.orders,
            _database.transactions,
          },
        )
        .watch()
        .asyncMap((_) => _loadSnapshot(DateTime.now()));
  }

  Future<DashboardSnapshot> _loadSnapshot(DateTime date) async {
    final todayRange = _dateRangeFor(date);
    final yesterdayRange = _dateRangeFor(
      date.subtract(const Duration(days: 1)),
    );

    final hasMenuItems = await _hasMenuItems();
    final todayPaid = await _loadPaidTotals(todayRange);
    final yesterdayPaid = await _loadPaidTotals(yesterdayRange);
    final completedOrdersToday = await _loadCompletedOrderCount(todayRange);
    final completedOrdersYesterday = await _loadCompletedOrderCount(
      yesterdayRange,
    );

    return DashboardSnapshot(
      generatedAt: date,
      hasMenuItems: hasMenuItems,
      totalSalesToday: todayPaid.totalAmount,
      totalSalesYesterday: yesterdayPaid.totalAmount,
      paidTransactionCountToday: todayPaid.transactionCount,
      paidTransactionCountYesterday: yesterdayPaid.transactionCount,
      averagePurchaseToday: _averagePurchase(todayPaid),
      averagePurchaseYesterday: _averagePurchase(yesterdayPaid),
      completedOrdersToday: completedOrdersToday,
      completedOrdersYesterday: completedOrdersYesterday,
      topMenuItems: await _loadTopMenuItems(todayRange),
      paymentMethodTotals: await _loadPaymentMethodTotals(todayRange),
      recentOrders: await _loadRecentOrders(todayRange),
    );
  }

  Future<bool> _hasMenuItems() async {
    final row = await _database
        .customSelect('SELECT COUNT(*) AS item_count FROM menu_items')
        .getSingle();

    return row.read<int>('item_count') > 0;
  }

  Future<_PaidTotals> _loadPaidTotals(_DateRange range) async {
    final row = await _database
        .customSelect(
          '''
          SELECT
            COALESCE(SUM(total_amount), 0) AS total_amount,
            COUNT(*) AS transaction_count
          FROM transactions
          WHERE paid_at >= ? AND paid_at < ?
          ''',
          variables: [
            Variable<String>(range.startIso),
            Variable<String>(range.endIso),
          ],
          readsFrom: {_database.transactions},
        )
        .getSingle();

    return _PaidTotals(
      totalAmount: row.read<int>('total_amount'),
      transactionCount: row.read<int>('transaction_count'),
    );
  }

  Future<int> _loadCompletedOrderCount(_DateRange range) async {
    final row = await _database
        .customSelect(
          '''
          SELECT COUNT(*) AS order_count
          FROM orders
          WHERE status = ?
            AND updated_at >= ?
            AND updated_at < ?
          ''',
          variables: [
            Variable<String>(OrderStatus.completed.databaseValue),
            Variable<String>(range.startIso),
            Variable<String>(range.endIso),
          ],
          readsFrom: {_database.orders},
        )
        .getSingle();

    return row.read<int>('order_count');
  }

  Future<List<DashboardTopMenuItem>> _loadTopMenuItems(_DateRange range) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT
            order_items.menu_item_id AS menu_item_id,
            order_items.menu_item_name AS name,
            categories.name AS category,
            SUM(order_items.quantity) AS ordered_count,
            SUM(order_items.subtotal) AS revenue
          FROM transactions
          INNER JOIN orders ON orders.id = transactions.order_id
          INNER JOIN order_items ON order_items.order_id = orders.id
          INNER JOIN menu_items ON menu_items.id = order_items.menu_item_id
          INNER JOIN categories ON categories.id = menu_items.category_id
          WHERE transactions.paid_at >= ?
            AND transactions.paid_at < ?
          GROUP BY
            order_items.menu_item_id,
            order_items.menu_item_name,
            categories.name
          ORDER BY revenue DESC, ordered_count DESC, name ASC
          ''',
          variables: [
            Variable<String>(range.startIso),
            Variable<String>(range.endIso),
          ],
          readsFrom: {
            _database.categories,
            _database.menuItems,
            _database.orderItems,
            _database.orders,
            _database.transactions,
          },
        )
        .get();

    final totalRevenue = rows.fold<int>(
      0,
      (sum, row) => sum + row.read<int>('revenue'),
    );

    return List.unmodifiable(
      rows.take(_listLimit).map((row) {
        final revenue = row.read<int>('revenue');
        return DashboardTopMenuItem(
          menuItemId: row.read<int>('menu_item_id'),
          name: row.read<String>('name'),
          category: row.read<String>('category'),
          orderedCount: row.read<int>('ordered_count'),
          revenue: revenue,
          revenueShare: totalRevenue == 0 ? 0 : revenue / totalRevenue,
        );
      }),
    );
  }

  Future<List<DashboardPaymentMethodTotal>> _loadPaymentMethodTotals(
    _DateRange range,
  ) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT
            payment_method,
            COALESCE(SUM(total_amount), 0) AS total_amount,
            COUNT(*) AS transaction_count
          FROM transactions
          WHERE paid_at >= ? AND paid_at < ?
          GROUP BY payment_method
          ''',
          variables: [
            Variable<String>(range.startIso),
            Variable<String>(range.endIso),
          ],
          readsFrom: {_database.transactions},
        )
        .get();

    final totalsByMethod = <OrderPaymentMethod, _PaymentMethodTotals>{};
    for (final row in rows) {
      final method = OrderPaymentMethod.fromDatabaseValue(
        row.read<String>('payment_method'),
      );
      totalsByMethod[method] = _PaymentMethodTotals(
        totalAmount: row.read<int>('total_amount'),
        transactionCount: row.read<int>('transaction_count'),
      );
    }

    final totalRevenue = totalsByMethod.values.fold<int>(
      0,
      (sum, total) => sum + total.totalAmount,
    );

    return List.unmodifiable(
      OrderPaymentMethod.values.map((method) {
        final totals = totalsByMethod[method] ?? const _PaymentMethodTotals();
        return DashboardPaymentMethodTotal(
          method: method,
          totalAmount: totals.totalAmount,
          transactionCount: totals.transactionCount,
          share: totalRevenue == 0 ? 0 : totals.totalAmount / totalRevenue,
        );
      }),
    );
  }

  Future<List<DashboardRecentOrder>> _loadRecentOrders(_DateRange range) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT
            orders.id AS order_id,
            orders.order_number AS order_number,
            orders.customer_name AS customer_name,
            orders.status AS status,
            transactions.total_amount AS total_amount,
            transactions.paid_at AS paid_at,
            COALESCE(SUM(order_items.quantity), 0) AS item_count
          FROM transactions
          INNER JOIN orders ON orders.id = transactions.order_id
          LEFT JOIN order_items ON order_items.order_id = orders.id
          WHERE transactions.paid_at >= ?
            AND transactions.paid_at < ?
          GROUP BY
            transactions.id,
            orders.id,
            orders.order_number,
            orders.customer_name,
            orders.status,
            transactions.total_amount,
            transactions.paid_at
          ORDER BY transactions.paid_at DESC
          LIMIT $_listLimit
          ''',
          variables: [
            Variable<String>(range.startIso),
            Variable<String>(range.endIso),
          ],
          readsFrom: {
            _database.orderItems,
            _database.orders,
            _database.transactions,
          },
        )
        .get();

    return List.unmodifiable(
      rows.map((row) {
        return DashboardRecentOrder(
          orderId: row.read<int>('order_id'),
          orderNumber: row.read<String>('order_number'),
          customerName: row.read<String?>('customer_name'),
          status: OrderStatus.fromDatabaseValue(row.read<String>('status')),
          itemCount: row.read<int>('item_count'),
          totalAmount: row.read<int>('total_amount'),
          paidAt: DateTime.parse(row.read<String>('paid_at')),
        );
      }),
    );
  }

  int _averagePurchase(_PaidTotals totals) {
    if (totals.transactionCount == 0) return 0;

    return (totals.totalAmount / totals.transactionCount).round();
  }

  _DateRange _dateRangeFor(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _DateRange(
      startIso: start.toIso8601String(),
      endIso: end.toIso8601String(),
    );
  }
}

class _PaidTotals {
  const _PaidTotals({
    required this.totalAmount,
    required this.transactionCount,
  });

  final int totalAmount;
  final int transactionCount;
}

class _PaymentMethodTotals {
  const _PaymentMethodTotals({this.totalAmount = 0, this.transactionCount = 0});

  final int totalAmount;
  final int transactionCount;
}

class _DateRange {
  const _DateRange({required this.startIso, required this.endIso});

  final String startIso;
  final String endIso;
}

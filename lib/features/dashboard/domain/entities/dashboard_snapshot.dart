import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order_payment_method.dart';
import '../../../orders/domain/entities/order_status.dart';

class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.generatedAt,
    required this.hasMenuItems,
    required this.totalSalesToday,
    required this.totalSalesYesterday,
    required this.paidTransactionCountToday,
    required this.paidTransactionCountYesterday,
    required this.averagePurchaseToday,
    required this.averagePurchaseYesterday,
    required this.completedOrdersToday,
    required this.completedOrdersYesterday,
    required this.topMenuItems,
    required this.paymentMethodTotals,
    required this.recentOrders,
  });

  final DateTime generatedAt;
  final bool hasMenuItems;
  final int totalSalesToday;
  final int totalSalesYesterday;
  final int paidTransactionCountToday;
  final int paidTransactionCountYesterday;
  final int averagePurchaseToday;
  final int averagePurchaseYesterday;
  final int completedOrdersToday;
  final int completedOrdersYesterday;
  final List<DashboardTopMenuItem> topMenuItems;
  final List<DashboardPaymentMethodTotal> paymentMethodTotals;
  final List<DashboardRecentOrder> recentOrders;

  bool get hasTodayData {
    return paidTransactionCountToday > 0 || completedOrdersToday > 0;
  }

  @override
  List<Object?> get props {
    return [
      generatedAt,
      hasMenuItems,
      totalSalesToday,
      totalSalesYesterday,
      paidTransactionCountToday,
      paidTransactionCountYesterday,
      averagePurchaseToday,
      averagePurchaseYesterday,
      completedOrdersToday,
      completedOrdersYesterday,
      topMenuItems,
      paymentMethodTotals,
      recentOrders,
    ];
  }
}

class DashboardTopMenuItem extends Equatable {
  const DashboardTopMenuItem({
    required this.menuItemId,
    required this.name,
    required this.category,
    required this.orderedCount,
    required this.revenue,
    required this.revenueShare,
  });

  final int menuItemId;
  final String name;
  final String category;
  final int orderedCount;
  final int revenue;
  final double revenueShare;

  @override
  List<Object?> get props {
    return [menuItemId, name, category, orderedCount, revenue, revenueShare];
  }
}

class DashboardPaymentMethodTotal extends Equatable {
  const DashboardPaymentMethodTotal({
    required this.method,
    required this.totalAmount,
    required this.transactionCount,
    required this.share,
  });

  final OrderPaymentMethod method;
  final int totalAmount;
  final int transactionCount;
  final double share;

  @override
  List<Object?> get props {
    return [method, totalAmount, transactionCount, share];
  }
}

class DashboardRecentOrder extends Equatable {
  const DashboardRecentOrder({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.itemCount,
    required this.totalAmount,
    required this.paidAt,
  });

  final int orderId;
  final String orderNumber;
  final String? customerName;
  final OrderStatus status;
  final int itemCount;
  final int totalAmount;
  final DateTime paidAt;

  String get customerLabel {
    final value = customerName?.trim();
    return value == null || value.isEmpty ? 'Order Baru' : value;
  }

  @override
  List<Object?> get props {
    return [
      orderId,
      orderNumber,
      customerName,
      status,
      itemCount,
      totalAmount,
      paidAt,
    ];
  }
}

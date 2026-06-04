import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/menu/presentation/menu_management_page.dart';
import '../features/orders/domain/entities/order_entity.dart';
import '../features/orders/presentation/order_summary_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/payment/presentation/cash_payment_page.dart';
import '../features/payment/presentation/qris_payment_page.dart';
import '../features/report/presentation/report_page.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: "/dashboard",
  routes: [
    GoRoute(path: "/", redirect: (context, state) => "/dashboard"),
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: "/dashboard",
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: "/orders",
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: "/orders/summary",
          builder: (context, state) {
            final extra = state.extra;
            return OrderSummaryPage(order: extra is OrderEntity ? extra : null);
          },
        ),
        GoRoute(
          path: "/orders/cash-payment",
          builder: (context, state) {
            final extra = state.extra;
            return CashPaymentPage(order: extra is OrderEntity ? extra : null);
          },
        ),
        GoRoute(
          path: "/orders/qris-payment",
          builder: (context, state) {
            final extra = state.extra;
            return QrisPaymentPage(order: extra is OrderEntity ? extra : null);
          },
        ),
        GoRoute(
          path: "/menu",
          builder: (context, state) => const MenuManagementPage(),
        ),
        GoRoute(
          path: "/report",
          builder: (context, state) => const ReportPage(),
        ),
        GoRoute(
          path: "/settings",
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_scaffold_with_navbar.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/menus/display/menus_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/splash/splash.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: "/splash",
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: "/splash",
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => SplashCubit()..initializeApp(),
            child: const SplashScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(
                curve: Curves.easeInOutCirc,
              ).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppScaffoldWithNavbar(key: state.pageKey, child: child);
      },
      routes: [
        GoRoute(
          path: "/dashboard",
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: "/menus",
          pageBuilder: (_, _) => const NoTransitionPage(child: MenusScreen()),
        ),
        GoRoute(
          path: "/orders",
          pageBuilder: (_, _) => const NoTransitionPage(child: OrdersScreen()),
        ),
        GoRoute(
          path: "/reports",
          pageBuilder: (_, _) => const NoTransitionPage(child: OrdersScreen()),
        ),
        GoRoute(
          path: "/settings",
          pageBuilder: (_, _) => const NoTransitionPage(child: OrdersScreen()),
        ),
      ],
    ),
  ],
);

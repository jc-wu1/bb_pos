import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unicons/unicons.dart';

class AppScaffoldWithNavbar extends StatefulWidget {
  const AppScaffoldWithNavbar({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffoldWithNavbar> createState() => _AppScaffoldWithNavbarState();
}

class _AppScaffoldWithNavbarState extends State<AppScaffoldWithNavbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                const NavigationRailDestination(
                  icon: Icon(UniconsLine.home_alt),
                  label: Text('Dashboard'),
                ),
                const NavigationRailDestination(
                  icon: Icon(UniconsLine.receipt),
                  label: Text('Pesanan'),
                ),
                const NavigationRailDestination(
                  icon: Icon(UniconsLine.list_ul),
                  label: Text('Menu'),
                ),
                const NavigationRailDestination(
                  icon: Icon(UniconsLine.chart_pie),
                  label: Text('Laporan'),
                ),
                const NavigationRailDestination(
                  icon: Icon(UniconsLine.setting),
                  label: Text('Pengaturan'),
                ),
              ],
              selectedIndex: _getCurrentIndex(context),
              onDestinationSelected: (value) {
                switch (value) {
                  case 0:
                    context.go('/dashboard');
                  case 1:
                    context.go('/orders');
                  case 2:
                    context.go('/menus');
                  case 3:
                    context.go('/reports');
                  case 4:
                    context.go('/settings');
                  default:
                    context.go('/dashboard');
                    print("test");
                }
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final GoRouterState route = GoRouterState.of(context);
    final String location = route.uri.toString();
    if (location == '/dashboard') {
      return 0;
    }
    if (location == '/orders') {
      return 1;
    }
    if (location == '/menus') {
      return 2;
    }
    if (location == '/reports') {
      return 3;
    }
    if (location == '/settings') {
      return 4;
    }
    return 0;
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = View.of(context).viewPadding.top;
    return SizedBox(height: statusBarHeight);
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}

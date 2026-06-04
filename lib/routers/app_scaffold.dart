import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<String> scopes = <String>['https://www.googleapis.com/auth/drive'];

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const double _navigationRailBreakpoint = 600;

  final List<_NavigationItem> _items = const [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      path: '/dashboard',
    ),
    _NavigationItem(
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      path: '/orders',
    ),
    _NavigationItem(
      label: 'Menu',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu,
      path: '/menu',
    ),
    // _NavigationItem(
    //   label: 'Report',
    //   icon: Icons.bar_chart_outlined,
    //   selectedIcon: Icons.bar_chart,
    //   path: '/report',
    // ),
    _NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      path: '/settings',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _items.indexWhere(
      (item) => location == item.path || location.startsWith('${item.path}/'),
    );

    return index == -1 ? 0 : index;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final item = _items[index];
    final location = GoRouterState.of(context).uri.path;

    if (location != item.path) {
      context.go(item.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(context);
    final resizeToAvoidBottomInset = location != '/orders';

    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail =
            constraints.maxWidth >= _navigationRailBreakpoint;

        if (useNavigationRail) {
          return Scaffold(
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      _onDestinationSelected(context, index),
                  labelType: NavigationRailLabelType.all,
                  minWidth: 64,
                  destinations: _items
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => _onDestinationSelected(context, index),
            type: BottomNavigationBarType.fixed,
            iconSize: 22,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: _items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

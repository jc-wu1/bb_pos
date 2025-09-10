import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unicons/unicons.dart';

import 'main.dart';

const List<String> scopes = <String>['https://www.googleapis.com/auth/drive'];

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
              trailing: IconButton(
                onPressed: () async {
                  // Trigger the authentication flow
                  final signIn = GoogleSignIn.instance;

                  await signIn.initialize();
                  final googleUser = await signIn.authenticate(
                    scopeHint: scopes,
                  );

                  final GoogleSignInClientAuthorization? authorization =
                      await googleUser.authorizationClient
                          .authorizationForScopes(scopes);

                  // Obtain the auth details from the request
                  final googleAuth = googleUser.authentication;

                  // Create a new credential
                  final credential = GoogleAuthProvider.credential(
                    accessToken: authorization?.accessToken,
                    idToken: googleAuth.idToken,
                  );

                  // Once signed in, return the UserCredential
                  await auth.signInWithCredential(credential);
                },
                icon: const Icon(Icons.person),
              ),
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

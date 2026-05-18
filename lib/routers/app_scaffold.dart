import 'package:flutter/material.dart';

const List<String> scopes = <String>['https://www.googleapis.com/auth/drive'];

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Rewrite")));
  }
}

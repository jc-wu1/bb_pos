import 'package:flutter/material.dart';

import 'routers/app_router.dart';
import 'themes/themes.dart';

class BbPosApp extends StatelessWidget {
  const BbPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(
      context,
      "Open Sans",
      "Playfair Display",
    );

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'Bakmi Balap 19',
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: appRouter,
    );
  }
}

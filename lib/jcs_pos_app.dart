import 'package:flutter/material.dart';

import 'routers/routers.dart';
import 'themes/themes.dart';

class JcsPosApp extends StatelessWidget {
  const JcsPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(
      context,
      "Open Sans",
      "Playfair Display",
    );

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'JCS POS',
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: appRouter,
    );
  }
}

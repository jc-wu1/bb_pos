import 'package:flutter/material.dart';

import 'bb_pos_app.dart';
import 'core/dependencies/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDependencies();

  runApp(const BbPosApp());
}

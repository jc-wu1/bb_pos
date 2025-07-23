import 'dart:io';

import 'package:bb_pos/features/receipt/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'jcs_pos_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // Workaround for https://github.com/flutter/flutter/issues/35162
    await FlutterDisplayMode.setHighRefreshRate();
  }

  late final Isar isar;

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([ReceiptSchema, ProductSchema], directory: dir.path);

  runApp(const JcsPosApp());
}

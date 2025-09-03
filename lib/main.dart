import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'jcs_pos_app.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const baseImgUrl = String.fromEnvironment('PUBLIC_IMG_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  runApp(const JcsPosApp());
}

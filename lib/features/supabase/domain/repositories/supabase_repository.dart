import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseRepository {
  Future<String> uploadImage(File imageFile);
  Future<FileObject> deleteImage(String path);
}

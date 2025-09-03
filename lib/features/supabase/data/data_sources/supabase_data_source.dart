import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseDataSource {
  Future<String> uploadImage(File fileImage);
  Future<FileObject> removeFile(String path);
}

class SupabaseDataSourceImpl implements SupabaseDataSource {
  @override
  Future<String> uploadImage(File fileImage) async {
    final path = "uploads/${DateTime.now().millisecondsSinceEpoch}";
    final uploadResult = await Supabase.instance.client.storage
        .from("m_images")
        .upload(path, fileImage);
    return uploadResult;
  }

  @override
  Future<FileObject> removeFile(String path) async {
    final uploadResult = await Supabase.instance.client.storage
        .from("m_images")
        .remove([path]);
    return uploadResult.first;
  }
}

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/supabase_repository.dart';

class SupabaseUsecase {
  final SupabaseRepository repository;

  SupabaseUsecase({required this.repository});

  Future<String> uploadImage(File imageFile) async {
    try {
      return await repository.uploadImage(imageFile);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<FileObject> deleteUploadedImage(String path) async {
    try {
      return await repository.deleteImage(path);
    } catch (e) {
      throw Exception(e);
    }
  }
}

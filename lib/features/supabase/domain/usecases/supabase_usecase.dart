import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../repositories/supabase_repository.dart';

class SupabaseUsecase {
  final SupabaseRepository repository;

  SupabaseUsecase({required this.repository});

  Future<TaskSnapshot> uploadImage(File imageFile) async {
    try {
      return await repository.uploadImage(imageFile);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteUploadedImage(String path) async {
    try {
      return await repository.deleteImage(path);
    } catch (e) {
      throw Exception(e);
    }
  }
}

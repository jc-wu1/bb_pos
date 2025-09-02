import 'dart:io';

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
}

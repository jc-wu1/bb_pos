import 'dart:io';

import '../repositories/supabase_repository.dart';

class SupabaseUsecase {
  final SupabaseRepository repository;

  SupabaseUsecase({required this.repository});

  static File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      return await repository.uploadImage(imageFile);
    } catch (e) {
      throw Exception(e);
    }
  }
}

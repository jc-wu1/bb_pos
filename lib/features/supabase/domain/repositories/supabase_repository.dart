import 'dart:io';

abstract class SupabaseRepository {
  Future<String> uploadImage(File imageFile);
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class SupabaseRepository {
  Future<TaskSnapshot> uploadImage(File imageFile);
  Future<void> deleteImage(String path);
}

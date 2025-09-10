import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class SupabaseDataSource {
  Future<TaskSnapshot> uploadImage(File fileImage);
  Future<void> removeFile(String path);
}

class SupabaseDataSourceImpl implements SupabaseDataSource {
  @override
  Future<TaskSnapshot> uploadImage(File fileImage) async {
    final path = "uploads/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final uploadResult = await FirebaseStorage.instance
        .ref()
        .child(path)
        .putFile(fileImage);
    return uploadResult;
  }

  @override
  Future<void> removeFile(String path) async {
    await FirebaseStorage.instance.ref().child(path).delete();
  }
}

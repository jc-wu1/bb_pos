import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/repositories/supabase_repository.dart';
import '../data_sources/supabase_data_source.dart';

class SupabaseRepositoryImpl implements SupabaseRepository {
  final SupabaseDataSource dataSource;

  SupabaseRepositoryImpl({required this.dataSource});

  @override
  Future<TaskSnapshot> uploadImage(File imageFile) async {
    return await dataSource.uploadImage(imageFile);
  }

  @override
  Future<void> deleteImage(String path) async {
    return await dataSource.removeFile(path);
  }
}

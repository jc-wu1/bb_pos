import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/supabase_repository.dart';
import '../data_sources/supabase_data_source.dart';

class SupabaseRepositoryImpl implements SupabaseRepository {
  final SupabaseDataSource dataSource;

  SupabaseRepositoryImpl({required this.dataSource});

  @override
  Future<String> uploadImage(File imageFile) async {
    return await dataSource.uploadImage(imageFile);
  }

  @override
  Future<FileObject> deleteImage(String path) async {
    return await dataSource.removeFile(path);
  }
}

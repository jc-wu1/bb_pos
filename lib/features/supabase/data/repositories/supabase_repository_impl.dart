import 'dart:io';

import '../../domain/repositories/supabase_repository.dart';
import '../data_sources/supabase_data_source.dart';

class SupabaseRepositoryImpl implements SupabaseRepository {
  final SupabaseDataSource dataSource;

  SupabaseRepositoryImpl({required this.dataSource});

  @override
  Future<String> uploadImage(File imageFile) async {
    return await dataSource.uploadImage(imageFile);
  }
}

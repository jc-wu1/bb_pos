import 'package:bb_pos/features/categories/data/model/category.dart';

import '../../domain/repositories/categories_repository.dart';
import '../data_sources/categories_local_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesLocalDataSource _localDataSource;

  const CategoriesRepositoryImpl({
    required CategoriesLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<CategoryItem>> getCategories() {
    return _localDataSource.fetchCategories();
  }

  @override
  Future<int> insertCategory(CategoryItem category) {
    return _localDataSource.insertCategory(category);
  }
}

import '../../data/model/category.dart';

abstract class CategoriesRepository {
  Future<List<CategoryItem>> getCategories();
  Future<int> insertCategory(CategoryItem category);
}

import '../../data/model/category.dart';
import '../repositories/categories_repository.dart';

class CategoriesUsecase {
  final CategoriesRepository _repository;

  CategoriesUsecase({required CategoriesRepository repository})
    : _repository = repository;

  Future<List<CategoryItem>> getCategories() async =>
      await _repository.getCategories();

  Future<int> insertCategory(CategoryItem category) async =>
      await _repository.insertCategory(category);
}

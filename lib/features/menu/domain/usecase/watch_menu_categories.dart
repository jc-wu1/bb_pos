import '../entities/menu_category_entity.dart';
import '../repositories/menu_repository.dart';

class WatchMenuCategories {
  const WatchMenuCategories(this._repository);

  final MenuRepository _repository;

  Stream<List<MenuCategoryEntity>> call() {
    return _repository.watchCategories();
  }
}

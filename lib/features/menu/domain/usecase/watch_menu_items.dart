import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class WatchMenuItems {
  const WatchMenuItems(this._repository);

  final MenuRepository _repository;

  Stream<List<MenuItemEntity>> call() {
    return _repository.watchMenuItems();
  }
}

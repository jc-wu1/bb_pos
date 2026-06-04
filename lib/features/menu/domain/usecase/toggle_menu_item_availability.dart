import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class ToggleMenuItemAvailability {
  const ToggleMenuItemAvailability(this._repository);

  final MenuRepository _repository;

  Future<void> call(MenuItemEntity item) {
    return _repository.toggleMenuItemAvailability(item);
  }
}

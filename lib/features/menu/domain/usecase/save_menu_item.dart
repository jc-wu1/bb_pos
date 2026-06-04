import '../entities/menu_item_input.dart';
import '../repositories/menu_repository.dart';

class SaveMenuItem {
  const SaveMenuItem(this._repository);

  final MenuRepository _repository;

  Future<void> call(MenuItemInput input) {
    return _repository.saveMenuItem(input);
  }
}

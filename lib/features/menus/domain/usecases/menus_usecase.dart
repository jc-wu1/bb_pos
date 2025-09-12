import '../../data/model/menu_model.dart';
import '../repositories/menus_repository.dart';

class MenusUsecase {
  final MenusRepository _repository;

  MenusUsecase({required MenusRepository repository})
    : _repository = repository;

  Future<List<MenuItem>> getMenuItems({String? categoryName}) async =>
      await _repository.getMenuItems(categoryName: categoryName);

  Future<int> addMenuItem(MenuItem menuItem) async =>
      await _repository.insertMenuItem(menuItem);

  Future<int> deleteMenuItem(int menuId) async =>
      await _repository.deleteMenuItem(menuId);
}

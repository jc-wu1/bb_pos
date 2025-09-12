import '../../data/model/menu_model.dart';

abstract class MenusRepository {
  Future<List<MenuItem>> getMenuItems({String? categoryName});
  Future<int> insertMenuItem(MenuItem menuItem);
  Future<int> deleteMenuItem(int menuId);
}

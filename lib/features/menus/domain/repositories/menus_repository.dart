import '../../data/model/menu_model.dart';

abstract class MenusRepository {
  Future<List<MenuItem>> getMenuItems();
  Future<int> insertMenuItem(MenuItem menuItem);
}

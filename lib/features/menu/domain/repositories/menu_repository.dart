import '../entities/menu_category_entity.dart';
import '../entities/menu_item_entity.dart';
import '../entities/menu_item_input.dart';

abstract interface class MenuRepository {
  Stream<List<MenuCategoryEntity>> watchCategories();

  Stream<List<MenuItemEntity>> watchMenuItems();

  Future<void> saveMenuItem(MenuItemInput input);

  Future<void> deleteMenuItem(MenuItemEntity item);

  Future<void> toggleMenuItemAvailability(MenuItemEntity item);
}

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/menu_item_entity.dart';
import 'menu_category_model.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.description,
    required super.imagePath,
    required super.isAvailable,
  });

  factory MenuItemModel.fromDatabase({
    required db.MenuItem item,
    required db.Category category,
  }) {
    return MenuItemModel(
      id: item.id,
      name: item.name,
      category: MenuCategoryModel.fromDatabase(category),
      price: item.price,
      description: item.description ?? '',
      imagePath: item.imagePath,
      isAvailable: item.isAvailable,
    );
  }
}

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/menu_category_entity.dart';

class MenuCategoryModel extends MenuCategoryEntity {
  const MenuCategoryModel({
    required super.id,
    required super.name,
    required super.displayOrder,
  });

  factory MenuCategoryModel.fromDatabase(db.Category category) {
    return MenuCategoryModel(
      id: category.id,
      name: category.name,
      displayOrder: category.displayOrder,
    );
  }
}

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/order_menu_category_entity.dart';

class OrderMenuCategoryModel extends OrderMenuCategoryEntity {
  const OrderMenuCategoryModel({
    required super.id,
    required super.name,
    required super.displayOrder,
  });

  factory OrderMenuCategoryModel.fromDatabase(db.Category category) {
    return OrderMenuCategoryModel(
      id: category.id,
      name: category.name,
      displayOrder: category.displayOrder,
    );
  }
}

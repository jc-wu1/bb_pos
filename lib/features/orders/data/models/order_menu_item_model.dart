import '../../../../core/database/database.dart' as db;
import '../../domain/entities/order_menu_item_entity.dart';
import 'order_menu_category_model.dart';

class OrderMenuItemModel extends OrderMenuItemEntity {
  const OrderMenuItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    required super.imagePath,
    required super.isAvailable,
    required super.displayOrder,
  });

  factory OrderMenuItemModel.fromDatabase({
    required db.MenuItem item,
    required db.Category category,
  }) {
    return OrderMenuItemModel(
      id: item.id,
      name: item.name,
      category: OrderMenuCategoryModel.fromDatabase(category),
      price: item.price,
      imagePath: item.imagePath,
      isAvailable: item.isAvailable,
      displayOrder: item.displayOrder,
    );
  }
}

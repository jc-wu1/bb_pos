import 'package:equatable/equatable.dart';

import 'order_menu_category_entity.dart';

class OrderMenuItemEntity extends Equatable {
  const OrderMenuItemEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    required this.isAvailable,
    required this.displayOrder,
  });

  final int id;
  final String name;
  final OrderMenuCategoryEntity category;
  final int price;
  final String? imagePath;
  final bool isAvailable;
  final int displayOrder;

  @override
  List<Object?> get props {
    return [id, name, category, price, imagePath, isAvailable, displayOrder];
  }
}

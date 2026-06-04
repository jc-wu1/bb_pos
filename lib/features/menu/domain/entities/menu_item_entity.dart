import 'package:equatable/equatable.dart';

import 'menu_category_entity.dart';

class MenuItemEntity extends Equatable {
  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.isAvailable,
  });

  final int id;
  final String name;
  final MenuCategoryEntity category;
  final int price;
  final String description;
  final String? imagePath;
  final bool isAvailable;

  @override
  List<Object?> get props {
    return [id, name, category, price, description, imagePath, isAvailable];
  }
}

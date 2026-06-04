import 'package:equatable/equatable.dart';

class MenuItemInput extends Equatable {
  const MenuItemInput({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.pickedImagePath,
    required this.removeImage,
  });

  final int? id;
  final int categoryId;
  final String name;
  final int price;
  final String description;
  final String? imagePath;
  final String? pickedImagePath;
  final bool removeImage;

  @override
  List<Object?> get props {
    return [
      id,
      categoryId,
      name,
      price,
      description,
      imagePath,
      pickedImagePath,
      removeImage,
    ];
  }
}

import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int? categoryId;
  final String category;

  const MenuItem({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    required this.category,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: map['price'] as double,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toMapInsert() => {
    'category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
  };

  @override
  List<Object?> get props => [id, name, price];
}

import 'package:equatable/equatable.dart';

class CategoryItem extends Equatable {
  final int? id;
  final String name;
  final String? description;

  const CategoryItem({this.id, required this.name, this.description});

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
  };

  @override
  List<Object?> get props => [id, name];
}

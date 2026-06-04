import 'package:equatable/equatable.dart';

class MenuCategoryEntity extends Equatable {
  const MenuCategoryEntity({
    required this.id,
    required this.name,
    required this.displayOrder,
  });

  final int id;
  final String name;
  final int displayOrder;

  @override
  List<Object?> get props => [id, name, displayOrder];
}

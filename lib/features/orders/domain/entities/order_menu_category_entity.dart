import 'package:equatable/equatable.dart';

class OrderMenuCategoryEntity extends Equatable {
  const OrderMenuCategoryEntity({
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

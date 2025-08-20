part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object> get props => [];
}

final class CategoriesFetched extends CategoriesEvent {
  const CategoriesFetched();
}

final class CategoryInserted extends CategoriesEvent {
  final CategoryItem categoryItem;

  const CategoryInserted({required this.categoryItem});

  @override
  List<Object> get props => [categoryItem];
}

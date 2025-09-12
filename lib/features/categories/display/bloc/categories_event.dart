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

final class CategoryDeleted extends CategoriesEvent {
  final int categoryId;

  const CategoryDeleted({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}

final class CategoryModified extends CategoriesEvent {
  final int categoryId;
  final CategoryItem categoryItem;

  const CategoryModified({
    required this.categoryId,
    required this.categoryItem,
  });

  @override
  List<Object> get props => [categoryId, categoryItem];
}

part of 'categories_bloc.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => [];
}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoadInProgress extends CategoriesState {}

final class CategoriesLoadComplete extends CategoriesState {
  final List<CategoryItem> categories;

  const CategoriesLoadComplete({required this.categories});

  @override
  List<Object> get props => [categories];
}

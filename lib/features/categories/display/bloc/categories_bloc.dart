import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/category.dart';
import '../../domain/usecases/categories_usecase.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesUsecase _usecase;
  CategoriesBloc({required CategoriesUsecase usecase})
    : _usecase = usecase,
      super(CategoriesInitial()) {
    on<CategoriesFetched>(_onCategoriesFetched);
    on<CategoryInserted>(_onCategoryInserted);
  }

  Future<void> _onCategoriesFetched(
    CategoriesFetched event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoadInProgress());
    final result = await _usecase.getCategories();
    emit(CategoriesLoadComplete(categories: result));
  }

  Future<void> _onCategoryInserted(
    CategoryInserted event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoadInProgress());
    await _usecase.insertCategory(event.categoryItem);
    add(const CategoriesFetched());
  }
}

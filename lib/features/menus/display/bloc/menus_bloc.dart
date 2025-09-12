import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/model/menu_model.dart';
import '../../domain/usecases/menus_usecase.dart';

part 'menus_event.dart';
part 'menus_state.dart';

class MenusBloc extends Bloc<MenusEvent, MenusState> {
  final MenusUsecase _usecase;

  MenusBloc({required MenusUsecase usecase})
    : _usecase = usecase,
      super(MenusInitial()) {
    on<MenusFetched>(_onMenuFetched);
    on<MenuInserted>(_onMenuInserted);
    on<MenuDeleted>(_onMenuDeleted);
  }

  Future<void> _onMenuFetched(
    MenusFetched event,
    Emitter<MenusState> emit,
  ) async {
    emit(MenusLoadInProgress());
    final result = await _usecase.getMenuItems(
      categoryName: event.categoryName,
    );
    emit(MenusLoadComplete(menus: result));
  }

  Future<void> _onMenuInserted(
    MenuInserted event,
    Emitter<MenusState> emit,
  ) async {
    await _usecase.addMenuItem(event.menuItem);
    add(const MenusFetched());
  }

  Future<void> _onMenuDeleted(
    MenuDeleted event,
    Emitter<MenusState> emit,
  ) async {
    await _usecase.deleteMenuItem(event.menuId);
    add(const MenusFetched());
  }
}

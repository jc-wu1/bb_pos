part of 'menus_bloc.dart';

sealed class MenusEvent extends Equatable {
  const MenusEvent();

  @override
  List<Object> get props => [];
}

final class MenusFetched extends MenusEvent {
  final String? categoryName;
  const MenusFetched({this.categoryName});
}

final class MenuInserted extends MenusEvent {
  final MenuItem menuItem;

  const MenuInserted({required this.menuItem});

  @override
  List<Object> get props => [menuItem];
}

final class MenuDeleted extends MenusEvent {
  final int menuId;

  const MenuDeleted({required this.menuId});

  @override
  List<Object> get props => [menuId];
}

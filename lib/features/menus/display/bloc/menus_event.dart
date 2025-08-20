part of 'menus_bloc.dart';

sealed class MenusEvent extends Equatable {
  const MenusEvent();

  @override
  List<Object> get props => [];
}

final class MenusFetched extends MenusEvent {
  const MenusFetched();
}

final class MenuInserted extends MenusEvent {
  final MenuItem menuItem;

  const MenuInserted({required this.menuItem});

  @override
  List<Object> get props => [menuItem];
}

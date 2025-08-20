part of 'menus_bloc.dart';

sealed class MenusState extends Equatable {
  const MenusState();

  @override
  List<Object> get props => [];
}

final class MenusInitial extends MenusState {}

final class MenusLoadInProgress extends MenusState {}

final class MenusLoadComplete extends MenusState {
  final List<MenuItem> menus;

  const MenusLoadComplete({required this.menus});

  @override
  List<Object> get props => [menus];
}

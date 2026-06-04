part of 'menu_management_cubit.dart';

const Object _stateFieldNotSet = Object();

enum MenuManagementStatus { initial, loading, ready, failure }

enum MenuManagementAction { none, saving, deleting, toggling }

class MenuManagementState extends Equatable {
  const MenuManagementState({
    required this.status,
    required this.activeAction,
    required this.categories,
    required this.items,
    required this.visibleItems,
    required this.selectedCategory,
    required this.searchQuery,
    required this.errorMessage,
    required this.errorSerial,
  });

  factory MenuManagementState.initial() {
    return const MenuManagementState(
      status: MenuManagementStatus.initial,
      activeAction: MenuManagementAction.none,
      categories: [],
      items: [],
      visibleItems: [],
      selectedCategory: null,
      searchQuery: '',
      errorMessage: null,
      errorSerial: 0,
    );
  }

  final MenuManagementStatus status;
  final MenuManagementAction activeAction;
  final List<MenuCategoryEntity> categories;
  final List<MenuItemEntity> items;
  final List<MenuItemEntity> visibleItems;
  final MenuCategoryEntity? selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final int errorSerial;

  bool get isInitialLoading {
    return status == MenuManagementStatus.loading && items.isEmpty;
  }

  MenuManagementState copyWith({
    MenuManagementStatus? status,
    MenuManagementAction? activeAction,
    List<MenuCategoryEntity>? categories,
    List<MenuItemEntity>? items,
    List<MenuItemEntity>? visibleItems,
    Object? selectedCategory = _stateFieldNotSet,
    String? searchQuery,
    Object? errorMessage = _stateFieldNotSet,
    bool clearErrorMessage = false,
    int? errorSerial,
  }) {
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _stateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;

    return MenuManagementState(
      status: status ?? this.status,
      activeAction: activeAction ?? this.activeAction,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      visibleItems: visibleItems ?? this.visibleItems,
      selectedCategory: identical(selectedCategory, _stateFieldNotSet)
          ? this.selectedCategory
          : selectedCategory as MenuCategoryEntity?,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: resolvedErrorMessage,
      errorSerial: errorSerial ?? this.errorSerial,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      activeAction,
      categories,
      items,
      visibleItems,
      selectedCategory,
      searchQuery,
      errorMessage,
      errorSerial,
    ];
  }
}

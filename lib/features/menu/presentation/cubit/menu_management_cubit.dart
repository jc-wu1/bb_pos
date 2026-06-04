import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_item_input.dart';
import '../../domain/usecase/delete_menu_item.dart';
import '../../domain/usecase/save_menu_item.dart';
import '../../domain/usecase/toggle_menu_item_availability.dart';
import '../../domain/usecase/watch_menu_categories.dart';
import '../../domain/usecase/watch_menu_items.dart';

part 'menu_management_state.dart';

class MenuManagementCubit extends Cubit<MenuManagementState> {
  MenuManagementCubit({
    required WatchMenuCategories watchMenuCategories,
    required WatchMenuItems watchMenuItems,
    required SaveMenuItem saveMenuItem,
    required DeleteMenuItem deleteMenuItem,
    required ToggleMenuItemAvailability toggleMenuItemAvailability,
  }) : _watchMenuCategories = watchMenuCategories,
       _watchMenuItems = watchMenuItems,
       _saveMenuItem = saveMenuItem,
       _deleteMenuItem = deleteMenuItem,
       _toggleMenuItemAvailability = toggleMenuItemAvailability,
       super(MenuManagementState.initial());

  final WatchMenuCategories _watchMenuCategories;
  final WatchMenuItems _watchMenuItems;
  final SaveMenuItem _saveMenuItem;
  final DeleteMenuItem _deleteMenuItem;
  final ToggleMenuItemAvailability _toggleMenuItemAvailability;

  StreamSubscription<List<MenuCategoryEntity>>? _categoriesSubscription;
  StreamSubscription<List<MenuItemEntity>>? _itemsSubscription;
  bool _isStarted = false;

  void load() {
    if (_isStarted) return;
    _isStarted = true;

    emit(state.copyWith(status: MenuManagementStatus.loading));

    _categoriesSubscription = _watchMenuCategories().listen(
      _onCategoriesChanged,
      onError: (Object error, StackTrace stackTrace) {
        _emitStreamFailure();
      },
    );
    _itemsSubscription = _watchMenuItems().listen(
      _onItemsChanged,
      onError: (Object error, StackTrace stackTrace) {
        _emitStreamFailure();
      },
    );
  }

  Future<void> retry() async {
    await _categoriesSubscription?.cancel();
    await _itemsSubscription?.cancel();
    _categoriesSubscription = null;
    _itemsSubscription = null;
    _isStarted = false;
    load();
  }

  void searchChanged(String query) {
    final nextQuery = query.trimLeft();
    emit(
      state.copyWith(
        searchQuery: nextQuery,
        visibleItems: _filterItems(
          items: state.items,
          selectedCategory: state.selectedCategory,
          searchQuery: nextQuery,
        ),
      ),
    );
  }

  void clearSearch() {
    searchChanged('');
  }

  void selectCategory(MenuCategoryEntity? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        visibleItems: _filterItems(
          items: state.items,
          selectedCategory: category,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama menu tidak boleh kosong.';
    }

    return null;
  }

  String? validateCategory(MenuCategoryEntity? value) {
    if (value == null) {
      return 'Kategori wajib dipilih.';
    }

    return null;
  }

  String? validatePrice(String? value) {
    final normalizedPrice = _digitsOnly(value ?? '');
    final price = int.tryParse(normalizedPrice);
    if (normalizedPrice.isEmpty) {
      return 'Harga tidak boleh kosong.';
    }

    if (price == null || price <= 0) {
      return 'Harga harus angka positif.';
    }

    return null;
  }

  Future<bool> saveMenuItem(MenuItemInput input) async {
    if (state.activeAction != MenuManagementAction.none) return false;

    emit(
      state.copyWith(
        activeAction: MenuManagementAction.saving,
        clearErrorMessage: true,
      ),
    );

    try {
      await _saveMenuItem(input);
      emit(state.copyWith(activeAction: MenuManagementAction.none));
      return true;
    } catch (_) {
      _emitActionFailure('Menu gagal disimpan. Coba lagi.');
      return false;
    }
  }

  Future<bool> deleteMenuItem(MenuItemEntity item) async {
    if (state.activeAction != MenuManagementAction.none) return false;

    emit(
      state.copyWith(
        activeAction: MenuManagementAction.deleting,
        clearErrorMessage: true,
      ),
    );

    try {
      await _deleteMenuItem(item);
      emit(state.copyWith(activeAction: MenuManagementAction.none));
      return true;
    } catch (_) {
      _emitActionFailure('Menu gagal dihapus. Coba lagi.');
      return false;
    }
  }

  Future<void> toggleAvailability(MenuItemEntity item) async {
    if (state.activeAction != MenuManagementAction.none) return;

    emit(
      state.copyWith(
        activeAction: MenuManagementAction.toggling,
        clearErrorMessage: true,
      ),
    );

    try {
      await _toggleMenuItemAvailability(item);
      emit(state.copyWith(activeAction: MenuManagementAction.none));
    } catch (_) {
      _emitActionFailure('Status menu gagal diubah. Coba lagi.');
    }
  }

  void _onCategoriesChanged(List<MenuCategoryEntity> categories) {
    final selectedCategory = _resolveSelectedCategory(
      selectedCategory: state.selectedCategory,
      categories: categories,
    );

    emit(
      state.copyWith(
        status:
            state.status == MenuManagementStatus.loading && state.items.isEmpty
            ? MenuManagementStatus.loading
            : MenuManagementStatus.ready,
        categories: List.unmodifiable(categories),
        selectedCategory: selectedCategory,
        visibleItems: _filterItems(
          items: state.items,
          selectedCategory: selectedCategory,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void _onItemsChanged(List<MenuItemEntity> items) {
    emit(
      state.copyWith(
        status: MenuManagementStatus.ready,
        items: List.unmodifiable(items),
        visibleItems: _filterItems(
          items: items,
          selectedCategory: state.selectedCategory,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void _emitStreamFailure() {
    emit(
      state.copyWith(
        status: MenuManagementStatus.failure,
        activeAction: MenuManagementAction.none,
        errorMessage: 'Data menu gagal dimuat.',
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  void _emitActionFailure(String message) {
    emit(
      state.copyWith(
        activeAction: MenuManagementAction.none,
        errorMessage: message,
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  MenuCategoryEntity? _resolveSelectedCategory({
    required MenuCategoryEntity? selectedCategory,
    required List<MenuCategoryEntity> categories,
  }) {
    if (selectedCategory == null) return null;

    for (final category in categories) {
      if (category.id == selectedCategory.id) return category;
    }

    return null;
  }

  List<MenuItemEntity> _filterItems({
    required List<MenuItemEntity> items,
    required MenuCategoryEntity? selectedCategory,
    required String searchQuery,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = items.where((item) {
      final isSameCategory =
          selectedCategory == null || item.category.id == selectedCategory.id;
      if (!isSameCategory) return false;
      if (query.isEmpty) return true;

      return item.name.toLowerCase().contains(query) ||
          item.category.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList()..sort(_compareMenuItems);

    return List.unmodifiable(filtered);
  }

  int _compareMenuItems(MenuItemEntity first, MenuItemEntity second) {
    final categoryComparison = first.category.displayOrder.compareTo(
      second.category.displayOrder,
    );
    if (categoryComparison != 0) return categoryComparison;

    return first.name.compareTo(second.name);
  }

  @override
  Future<void> close() async {
    await _categoriesSubscription?.cancel();
    await _itemsSubscription?.cancel();
    return super.close();
  }
}

String _digitsOnly(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

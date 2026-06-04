import 'dart:async';

import 'package:bb_pos/features/menu/domain/entities/menu_category_entity.dart';
import 'package:bb_pos/features/menu/domain/entities/menu_item_entity.dart';
import 'package:bb_pos/features/menu/domain/entities/menu_item_input.dart';
import 'package:bb_pos/features/menu/domain/repositories/menu_repository.dart';
import 'package:bb_pos/features/menu/domain/usecase/delete_menu_item.dart';
import 'package:bb_pos/features/menu/domain/usecase/save_menu_item.dart';
import 'package:bb_pos/features/menu/domain/usecase/toggle_menu_item_availability.dart';
import 'package:bb_pos/features/menu/domain/usecase/watch_menu_categories.dart';
import 'package:bb_pos/features/menu/domain/usecase/watch_menu_items.dart';
import 'package:bb_pos/features/menu/presentation/cubit/menu_management_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const foodCategory = MenuCategoryEntity(
    id: 1,
    name: 'Makanan',
    displayOrder: 1,
  );
  const drinkCategory = MenuCategoryEntity(
    id: 2,
    name: 'Minuman',
    displayOrder: 2,
  );

  MenuManagementCubit buildCubit(_FakeMenuRepository repository) {
    return MenuManagementCubit(
      watchMenuCategories: WatchMenuCategories(repository),
      watchMenuItems: WatchMenuItems(repository),
      saveMenuItem: SaveMenuItem(repository),
      deleteMenuItem: DeleteMenuItem(repository),
      toggleMenuItemAvailability: ToggleMenuItemAvailability(repository),
    );
  }

  test(
    'keeps the menu list empty when repository emits no menu items',
    () async {
      final repository = _FakeMenuRepository();
      final cubit = buildCubit(repository);
      addTearDown(cubit.close);
      addTearDown(repository.close);

      cubit.load();
      repository.emitCategories(const [foodCategory, drinkCategory]);
      repository.emitItems(const []);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, MenuManagementStatus.ready);
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.visibleItems, isEmpty);
    },
  );

  test('filters menu items by category and search query', () async {
    final repository = _FakeMenuRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    cubit.load();
    repository.emitCategories(const [foodCategory, drinkCategory]);
    repository.emitItems(const [
      MenuItemEntity(
        id: 1,
        name: 'Bakmi Ayam',
        category: foodCategory,
        price: 30000,
        description: 'Bakmi ayam gurih',
        imagePath: null,
        isAvailable: true,
      ),
      MenuItemEntity(
        id: 2,
        name: 'Es Teh Lemon',
        category: drinkCategory,
        price: 9000,
        description: 'Teh dingin',
        imagePath: null,
        isAvailable: true,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    cubit.selectCategory(drinkCategory);
    expect(cubit.state.visibleItems.map((item) => item.id), [2]);

    cubit.searchChanged('bakmi');
    expect(cubit.state.visibleItems, isEmpty);

    cubit.selectCategory(null);
    expect(cubit.state.visibleItems.map((item) => item.id), [1]);
  });

  test('accepts a formatted positive price', () {
    final repository = _FakeMenuRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    expect(cubit.validatePrice('30.000'), isNull);
  });
}

class _FakeMenuRepository implements MenuRepository {
  final _categoriesController =
      StreamController<List<MenuCategoryEntity>>.broadcast();
  final _itemsController = StreamController<List<MenuItemEntity>>.broadcast();

  void emitCategories(List<MenuCategoryEntity> categories) {
    _categoriesController.add(categories);
  }

  void emitItems(List<MenuItemEntity> items) {
    _itemsController.add(items);
  }

  Future<void> close() async {
    await _categoriesController.close();
    await _itemsController.close();
  }

  @override
  Stream<List<MenuCategoryEntity>> watchCategories() {
    return _categoriesController.stream;
  }

  @override
  Stream<List<MenuItemEntity>> watchMenuItems() {
    return _itemsController.stream;
  }

  @override
  Future<void> saveMenuItem(MenuItemInput input) async {}

  @override
  Future<void> deleteMenuItem(MenuItemEntity item) async {}

  @override
  Future<void> toggleMenuItemAvailability(MenuItemEntity item) async {}
}

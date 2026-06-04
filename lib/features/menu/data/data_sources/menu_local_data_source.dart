import 'package:drift/drift.dart';

import '../../../../core/database/database.dart' as db;
import '../../domain/entities/menu_item_input.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

abstract interface class MenuLocalDataSource {
  Stream<List<MenuCategoryModel>> watchCategories();

  Stream<List<MenuItemModel>> watchMenuItems();

  Future<void> saveMenuItem(MenuItemInput input, {required String? imagePath});

  Future<void> deleteMenuItem(int id);

  Future<void> updateAvailability({required int id, required bool isAvailable});
}

class DriftMenuLocalDataSource implements MenuLocalDataSource {
  const DriftMenuLocalDataSource(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<MenuCategoryModel>> watchCategories() {
    final query = _database.select(_database.categories)
      ..orderBy([
        (category) => OrderingTerm(expression: category.displayOrder),
        (category) => OrderingTerm(expression: category.name),
      ]);

    return query.watch().map((categories) {
      return List.unmodifiable(categories.map(MenuCategoryModel.fromDatabase));
    });
  }

  @override
  Stream<List<MenuItemModel>> watchMenuItems() {
    final query =
        _database.select(_database.menuItems).join([
          innerJoin(
            _database.categories,
            _database.categories.id.equalsExp(_database.menuItems.categoryId),
          ),
        ])..orderBy([
          OrderingTerm(expression: _database.categories.displayOrder),
          OrderingTerm(expression: _database.menuItems.name),
        ]);

    return query.watch().map((rows) {
      return List.unmodifiable(
        rows.map((row) {
          return MenuItemModel.fromDatabase(
            item: row.readTable(_database.menuItems),
            category: row.readTable(_database.categories),
          );
        }),
      );
    });
  }

  @override
  Future<void> saveMenuItem(
    MenuItemInput input, {
    required String? imagePath,
  }) async {
    await _database.transaction(() async {
      final now = DateTime.now().toIso8601String();
      final existing = input.id == null
          ? null
          : await _findMenuItemById(input.id!);

      if (input.id != null && existing == null) {
        throw StateError('Menu item ${input.id} was not found.');
      }

      final description = input.description.trim();
      final companion = db.MenuItemsCompanion(
        categoryId: Value(input.categoryId),
        name: Value(input.name.trim()),
        description: Value(description.isEmpty ? null : description),
        price: Value(input.price),
        imagePath: Value(imagePath),
        isAvailable: Value(existing?.isAvailable ?? true),
        displayOrder: Value(existing?.displayOrder ?? 1),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      );

      final id = input.id;
      if (id == null) {
        await _database.into(_database.menuItems).insert(companion);
      } else {
        await (_database.update(
          _database.menuItems,
        )..where((item) => item.id.equals(id))).write(companion);
      }
    });
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await (_database.delete(
      _database.menuItems,
    )..where((item) => item.id.equals(id))).go();
  }

  @override
  Future<void> updateAvailability({
    required int id,
    required bool isAvailable,
  }) async {
    await (_database.update(
      _database.menuItems,
    )..where((item) => item.id.equals(id))).write(
      db.MenuItemsCompanion(
        isAvailable: Value(isAvailable),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<db.MenuItem?> _findMenuItemById(int id) {
    return (_database.select(
      _database.menuItems,
    )..where((item) => item.id.equals(id))).getSingleOrNull();
  }
}

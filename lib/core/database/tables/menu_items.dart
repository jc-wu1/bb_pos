import 'package:drift/drift.dart';

import 'categories.dart';

class MenuItems extends Table {
  @override
  String get tableName => 'menu_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().named('category_id').references(Categories, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get price => integer()();
  TextColumn get imagePath => text().named('image_path').nullable()();
  BoolColumn get isAvailable =>
      boolean().named('is_available').withDefault(const Constant(true))();
  IntColumn get displayOrder => integer().named('display_order')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
}

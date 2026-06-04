import 'package:drift/drift.dart';

class Categories extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get displayOrder => integer().named('display_order')();
}

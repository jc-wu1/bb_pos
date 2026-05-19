import 'package:drift/drift.dart';

import 'menu_items.dart';
import 'orders.dart';

class OrderItems extends Table {
  @override
  String get tableName => 'order_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().named('order_id').references(Orders, #id)();
  IntColumn get menuItemId =>
      integer().named('menu_item_id').references(MenuItems, #id)();
  TextColumn get menuItemName => text().named('menu_item_name')();
  IntColumn get menuItemPrice => integer().named('menu_item_price')();
  IntColumn get quantity => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get subtotal => integer()();
}

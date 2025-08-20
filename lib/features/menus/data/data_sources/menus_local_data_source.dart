import 'package:sqflite/sqflite.dart';

import '../model/menu_model.dart';

abstract class MenusLocalDataSource {
  Future<List<MenuItem>> fetchMenuItems();
  Future<int> insertMenuItem(MenuItem menuItem);
}

class MenusLocalDataSourceImpl implements MenusLocalDataSource {
  final Database _db;

  const MenusLocalDataSourceImpl({required Database db}) : _db = db;

  @override
  Future<List<MenuItem>> fetchMenuItems() async {
    final List<Map<String, dynamic>> queryResult = await _db.rawQuery('''
      SELECT mi.id, mi.name, mi.description, mi.price, c.name AS category
      FROM tbl_menu_items mi
      JOIN tbl_categories c ON mi.category_id = c.id
    ''');
    return queryResult.map((map) => MenuItem.fromMap(map)).toList();
  }

  @override
  Future<int> insertMenuItem(MenuItem menuItem) async {
    final queryResult = await _db.rawInsert('''
      INSERT INTO tbl_menu_items (category_id, name, description, price)
      VALUES (1, 'Americano', 'Hot black coffee', 2.50)
    ''', []);
    return queryResult;
  }
}

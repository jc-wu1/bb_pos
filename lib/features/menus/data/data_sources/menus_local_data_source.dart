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
      SELECT mi.id, mi.name, mi.description, mi.price, mi.img_url, c.name AS category
      FROM tbl_menu_items mi
      JOIN tbl_categories c ON mi.category_id = c.id
    ''');
    return queryResult.map((map) => MenuItem.fromMap(map)).toList();
  }

  @override
  Future<int> insertMenuItem(MenuItem menuItem) async {
    final queryResult = await _db.insert(
      "tbl_menu_items",
      menuItem.toMapInsert(),
    );
    return queryResult;
  }
}

import 'package:sqflite/sqflite.dart';

import '../model/menu_model.dart';

abstract class MenusLocalDataSource {
  Future<List<MenuItem>> fetchMenuItems({String? categoryName});
  Future<int> insertMenuItem(MenuItem menuItem);
  Future<int> deleteMenuItem(int menuId);
}

class MenusLocalDataSourceImpl implements MenusLocalDataSource {
  final Database _db;

  const MenusLocalDataSourceImpl({required Database db}) : _db = db;

  @override
  Future<List<MenuItem>> fetchMenuItems({String? categoryName}) async {
    String sql = '''
      SELECT mi.id, mi.name, mi.description, mi.price, mi.img_url, c.name AS category
      FROM tbl_menu_items mi
      JOIN tbl_categories c ON mi.category_id = c.id
    ''';

    List<dynamic> args = [];
    if (categoryName != null && categoryName.isNotEmpty) {
      sql += ' WHERE c.name = ?';
      args.add(categoryName);
    }

    final List<Map<String, dynamic>> queryResult = await _db.rawQuery(
      sql,
      args,
    );

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

  @override
  Future<int> deleteMenuItem(int menuId) async {
    final queryResult = await _db.rawDelete(
      "DELETE FROM tbl_menu_items WHERE id = ?",
      [menuId],
    );
    return queryResult;
  }
}

import 'package:sqflite/sqflite.dart';

import '../model/category.dart';

abstract class CategoriesLocalDataSource {
  Future<List<CategoryItem>> fetchCategories();
  Future<int> insertCategory(CategoryItem category);
  Future<int> deleteCategory(int categoryId);
  Future<int> modifyCategory(int categoryId, CategoryItem category);
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  final Database _db;

  const CategoriesLocalDataSourceImpl({required Database db}) : _db = db;

  @override
  Future<List<CategoryItem>> fetchCategories() async {
    final List<Map<String, dynamic>> queryResult = await _db.query(
      'tbl_categories',
    );
    return queryResult.map((map) => CategoryItem.fromMap(map)).toList();
  }

  @override
  Future<int> insertCategory(CategoryItem category) async {
    final queryResult = await _db.insert(
      "tbl_categories",
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return queryResult;
  }

  @override
  Future<int> deleteCategory(int categoryId) async {
    final queryResult = await _db.rawDelete(
      "DELETE FROM tbl_categories WHERE id = ?",
      [categoryId],
    );
    return queryResult;
  }

  @override
  Future<int> modifyCategory(int categoryId, CategoryItem category) async {
    final queryResult = await _db.rawUpdate(
      '''
        UPDATE tbl_categories SET name = ?, description = ?
        WHERE id = ?
      ''',
      [category.name, category.description, categoryId],
    );
    return queryResult;
  }
}

import '../../domain/repositories/menus_repository.dart';
import '../data_sources/menus_local_data_source.dart';
import '../model/menu_model.dart';

class MenusRepositoryImpl implements MenusRepository {
  final MenusLocalDataSource _localDataSource;

  const MenusRepositoryImpl({required MenusLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<List<MenuItem>> getMenuItems({String? categoryName}) {
    return _localDataSource.fetchMenuItems(categoryName: categoryName);
  }

  @override
  Future<int> insertMenuItem(MenuItem menuItem) {
    return _localDataSource.insertMenuItem(menuItem);
  }

  @override
  Future<int> deleteMenuItem(int menuId) {
    return _localDataSource.deleteMenuItem(menuId);
  }
}

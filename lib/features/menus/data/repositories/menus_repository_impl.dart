import '../../domain/repositories/menus_repository.dart';
import '../data_sources/menus_local_data_source.dart';
import '../model/menu_model.dart';

class MenusRepositoryImpl implements MenusRepository {
  final MenusLocalDataSource _localDataSource;

  const MenusRepositoryImpl({required MenusLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<List<MenuItem>> getMenuItems() {
    return _localDataSource.fetchMenuItems();
  }

  @override
  Future<int> insertMenuItem(MenuItem menuItem) {
    return _localDataSource.insertMenuItem(menuItem);
  }
}

import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../features/categories/data/data_sources/categories_local_data_source.dart';
import '../features/categories/data/repositories/categories_repository_impl.dart';
import '../features/categories/domain/repositories/categories_repository.dart';
import '../features/categories/domain/usecases/categories_usecase.dart';
import '../features/menus/data/data_sources/menus_local_data_source.dart';
import '../features/menus/data/repositories/menus_repository_impl.dart';
import '../features/menus/domain/repositories/menus_repository.dart';
import '../features/menus/domain/usecases/menus_usecase.dart';
import 'db_services.dart';

final sl = GetIt.instance;

Future<void> initDbService() async {
  final DbServices dbServices = DbServices();
  sl.registerSingletonAsync<Database>(() async => await dbServices.database());
}

Future<void> initCoreDependencies() async {
  /// Data source
  sl.registerLazySingleton<CategoriesLocalDataSource>(
    () => CategoriesLocalDataSourceImpl(db: sl<Database>()),
  );
  sl.registerLazySingleton<MenusLocalDataSource>(
    () => MenusLocalDataSourceImpl(db: sl<Database>()),
  );
  ////

  /// Repositories
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      localDataSource: sl<CategoriesLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<MenusRepository>(
    () => MenusRepositoryImpl(localDataSource: sl<MenusLocalDataSource>()),
  );
  ////

  /// Usecase
  sl.registerLazySingleton<CategoriesUsecase>(
    () => CategoriesUsecase(repository: sl<CategoriesRepository>()),
  );
  sl.registerLazySingleton<MenusUsecase>(
    () => MenusUsecase(repository: sl<MenusRepository>()),
  );
  ////
}

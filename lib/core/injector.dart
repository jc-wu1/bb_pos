import 'package:bb_pos/features/supabase/data/data_sources/supabase_data_source.dart';
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
import '../features/supabase/data/repositories/supabase_repository_impl.dart';
import '../features/supabase/domain/repositories/supabase_repository.dart';
import '../features/supabase/domain/usecases/supabase_usecase.dart';
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
  sl.registerLazySingleton<SupabaseDataSource>(() => SupabaseDataSourceImpl());
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
  sl.registerLazySingleton<SupabaseRepository>(
    () => SupabaseRepositoryImpl(dataSource: sl<SupabaseDataSource>()),
  );
  ////

  /// Usecase
  sl.registerLazySingleton<CategoriesUsecase>(
    () => CategoriesUsecase(repository: sl<CategoriesRepository>()),
  );
  sl.registerLazySingleton<MenusUsecase>(
    () => MenusUsecase(repository: sl<MenusRepository>()),
  );
  sl.registerLazySingleton<SupabaseUsecase>(
    () => SupabaseUsecase(repository: sl<SupabaseRepository>()),
  );
  ////
}

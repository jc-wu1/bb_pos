import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import 'db_services.dart';

final sl = GetIt.instance;

Future<void> initDbService() async {
  final DbServices dbServices = DbServices();
  sl.registerSingletonAsync<Database>(() async => await dbServices.database());
}

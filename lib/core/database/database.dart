import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/categories.dart';
import 'tables/menu_items.dart';
import 'tables/order_items.dart';
import 'tables/orders.dart';
import 'tables/transactions.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Categories, MenuItems, Orders, OrderItems, Transactions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'bb_pos'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) async {
        await migrator.createAll();

        await batch((batch) {
          batch.insertAll(categories, [
            CategoriesCompanion.insert(
              id: const Value(1),
              name: 'Makanan',
              displayOrder: 1,
            ),
            CategoriesCompanion.insert(
              id: const Value(2),
              name: 'Minuman',
              displayOrder: 2,
            ),
            CategoriesCompanion.insert(
              id: const Value(3),
              name: 'Side Dish',
              displayOrder: 3,
            ),
          ]);
        });
      },
    );
  }
}

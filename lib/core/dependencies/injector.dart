import 'package:get_it/get_it.dart';

import '../../features/dashboard/data/data_sources/dashboard_local_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecase/watch_dashboard.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/menu/data/data_sources/menu_image_local_data_source.dart';
import '../../features/menu/data/data_sources/menu_local_data_source.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecase/delete_menu_item.dart';
import '../../features/menu/domain/usecase/save_menu_item.dart';
import '../../features/menu/domain/usecase/toggle_menu_item_availability.dart';
import '../../features/menu/domain/usecase/watch_menu_categories.dart';
import '../../features/menu/domain/usecase/watch_menu_items.dart';
import '../../features/menu/presentation/cubit/menu_management_cubit.dart';
import '../../features/orders/data/data_sources/orders_local_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecase/cancel_order.dart';
import '../../features/orders/domain/usecase/change_order_item_quantity.dart';
import '../../features/orders/domain/usecase/confirm_order_payment.dart';
import '../../features/orders/domain/usecase/create_order.dart';
import '../../features/orders/domain/usecase/set_order_item_quantity.dart';
import '../../features/orders/domain/usecase/watch_order_menu_items.dart';
import '../../features/orders/domain/usecase/watch_orders.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/payment/presentation/cubit/cash_payment_cubit.dart';
import '../../features/payment/presentation/cubit/qris_payment_cubit.dart';
import '../database/database.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(
    AppDatabase.new,
    dispose: (database) => database.close(),
  );
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DriftDashboardLocalDataSource(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () =>
        DashboardRepositoryImpl(dataSource: getIt<DashboardLocalDataSource>()),
  );
  getIt.registerLazySingleton(
    () => WatchDashboard(getIt<DashboardRepository>()),
  );
  getIt.registerFactory(
    () => DashboardCubit(watchDashboard: getIt<WatchDashboard>()),
  );
  getIt.registerLazySingleton<MenuLocalDataSource>(
    () => DriftMenuLocalDataSource(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<MenuImageLocalDataSource>(
    MenuImageLocalDataSource.new,
  );
  getIt.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      localDataSource: getIt<MenuLocalDataSource>(),
      imageDataSource: getIt<MenuImageLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton(
    () => WatchMenuCategories(getIt<MenuRepository>()),
  );
  getIt.registerLazySingleton(() => WatchMenuItems(getIt<MenuRepository>()));
  getIt.registerLazySingleton(() => SaveMenuItem(getIt<MenuRepository>()));
  getIt.registerLazySingleton(() => DeleteMenuItem(getIt<MenuRepository>()));
  getIt.registerLazySingleton(
    () => ToggleMenuItemAvailability(getIt<MenuRepository>()),
  );
  getIt.registerFactory(
    () => MenuManagementCubit(
      watchMenuCategories: getIt<WatchMenuCategories>(),
      watchMenuItems: getIt<WatchMenuItems>(),
      saveMenuItem: getIt<SaveMenuItem>(),
      deleteMenuItem: getIt<DeleteMenuItem>(),
      toggleMenuItemAvailability: getIt<ToggleMenuItemAvailability>(),
    ),
  );
  getIt.registerLazySingleton<OrdersLocalDataSource>(
    () => DriftOrdersLocalDataSource(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(localDataSource: getIt<OrdersLocalDataSource>()),
  );
  getIt.registerLazySingleton(() => WatchOrders(getIt<OrdersRepository>()));
  getIt.registerLazySingleton(
    () => WatchOrderMenuItems(getIt<OrdersRepository>()),
  );
  getIt.registerLazySingleton(() => CreateOrder(getIt<OrdersRepository>()));
  getIt.registerLazySingleton(
    () => ChangeOrderItemQuantity(getIt<OrdersRepository>()),
  );
  getIt.registerLazySingleton(
    () => SetOrderItemQuantity(getIt<OrdersRepository>()),
  );
  getIt.registerLazySingleton(() => CancelOrder(getIt<OrdersRepository>()));
  getIt.registerLazySingleton(
    () => ConfirmOrderPayment(getIt<OrdersRepository>()),
  );
  getIt.registerFactoryParam<CashPaymentCubit, OrderEntity?, void>(
    (order, _) => CashPaymentCubit(
      confirmOrderPayment: getIt<ConfirmOrderPayment>(),
      order: order,
    ),
  );
  getIt.registerFactoryParam<QrisPaymentCubit, OrderEntity?, void>(
    (order, _) => QrisPaymentCubit(
      confirmOrderPayment: getIt<ConfirmOrderPayment>(),
      order: order,
    ),
  );
  getIt.registerFactory(
    () => OrdersCubit(
      watchOrders: getIt<WatchOrders>(),
      watchMenuItems: getIt<WatchOrderMenuItems>(),
      createOrder: getIt<CreateOrder>(),
      changeOrderItemQuantity: getIt<ChangeOrderItemQuantity>(),
      setOrderItemQuantity: getIt<SetOrderItemQuantity>(),
      cancelOrder: getIt<CancelOrder>(),
    ),
  );
}

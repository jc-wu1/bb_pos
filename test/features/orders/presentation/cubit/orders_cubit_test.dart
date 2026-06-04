import 'dart:async';

import 'package:bb_pos/features/orders/domain/entities/confirm_order_payment_input.dart';
import 'package:bb_pos/features/orders/domain/entities/order_entity.dart';
import 'package:bb_pos/features/orders/domain/entities/order_item_quantity_input.dart';
import 'package:bb_pos/features/orders/domain/entities/order_line_entity.dart';
import 'package:bb_pos/features/orders/domain/entities/order_menu_category_entity.dart';
import 'package:bb_pos/features/orders/domain/entities/order_menu_item_entity.dart';
import 'package:bb_pos/features/orders/domain/entities/order_status.dart';
import 'package:bb_pos/features/orders/domain/entities/order_type.dart';
import 'package:bb_pos/features/orders/domain/entities/set_order_item_quantity_input.dart';
import 'package:bb_pos/features/orders/domain/repositories/orders_repository.dart';
import 'package:bb_pos/features/orders/domain/usecase/cancel_order.dart';
import 'package:bb_pos/features/orders/domain/usecase/change_order_item_quantity.dart';
import 'package:bb_pos/features/orders/domain/usecase/create_order.dart';
import 'package:bb_pos/features/orders/domain/usecase/set_order_item_quantity.dart';
import 'package:bb_pos/features/orders/domain/usecase/watch_order_menu_items.dart';
import 'package:bb_pos/features/orders/domain/usecase/watch_orders.dart';
import 'package:bb_pos/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const foodCategory = OrderMenuCategoryEntity(
    id: 1,
    name: 'Makanan',
    displayOrder: 1,
  );
  const drinkCategory = OrderMenuCategoryEntity(
    id: 2,
    name: 'Minuman',
    displayOrder: 2,
  );
  const bakmi = OrderMenuItemEntity(
    id: 1,
    name: 'Bakmi Ayam',
    category: foodCategory,
    price: 30000,
    imagePath: null,
    isAvailable: true,
    displayOrder: 1,
  );
  const esTeh = OrderMenuItemEntity(
    id: 2,
    name: 'Es Teh',
    category: drinkCategory,
    price: 9000,
    imagePath: null,
    isAvailable: true,
    displayOrder: 1,
  );
  const soldOutItem = OrderMenuItemEntity(
    id: 3,
    name: 'Nasi Ayam',
    category: foodCategory,
    price: 28000,
    imagePath: null,
    isAvailable: false,
    displayOrder: 2,
  );

  OrdersCubit buildCubit(_FakeOrdersRepository repository) {
    return OrdersCubit(
      watchOrders: WatchOrders(repository),
      watchMenuItems: WatchOrderMenuItems(repository),
      createOrder: CreateOrder(repository),
      changeOrderItemQuantity: ChangeOrderItemQuantity(repository),
      setOrderItemQuantity: SetOrderItemQuantity(repository),
      cancelOrder: CancelOrder(repository),
    );
  }

  test('selects the first emitted order and exposes item quantities', () async {
    final repository = _FakeOrdersRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    cubit.load();
    repository.emitOrders([_order(id: 1)]);
    repository.emitMenuItems(const [bakmi, esTeh]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, OrdersStatus.ready);
    expect(cubit.state.selectedOrderId, 1);
    expect(cubit.state.selectedItemQuantities, {1: 2});
  });

  test('filters menu items by category and search query', () async {
    final repository = _FakeOrdersRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    cubit.load();
    repository.emitOrders(const []);
    repository.emitMenuItems(const [bakmi, esTeh]);
    await Future<void>.delayed(Duration.zero);

    cubit.selectCategory(drinkCategory);
    expect(cubit.state.visibleMenuItems.map((item) => item.id), [2]);

    cubit.searchChanged('bakmi');
    expect(cubit.state.visibleMenuItems, isEmpty);

    cubit.selectCategory(null);
    expect(cubit.state.visibleMenuItems.map((item) => item.id), [1]);
  });

  test('creates an order and stores the pending selected order id', () async {
    final repository = _FakeOrdersRepository()..nextOrderId = 9;
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    await cubit.createOrder();

    expect(cubit.state.activeAction, OrdersAction.none);
    expect(cubit.state.selectedOrderId, 9);
  });

  test('does not increment unavailable menu items', () async {
    final repository = _FakeOrdersRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    cubit.load();
    repository.emitOrders([_order(id: 1)]);
    repository.emitMenuItems(const [bakmi, soldOutItem]);
    await Future<void>.delayed(Duration.zero);

    await cubit.incrementMenu(soldOutItem);
    expect(repository.quantityInputs, isEmpty);

    await cubit.incrementMenu(bakmi);
    expect(repository.quantityInputs.single.menuItemId, 1);
    expect(repository.quantityInputs.single.delta, 1);
  });

  test('sets and deletes order item quantity through use cases', () async {
    final repository = _FakeOrdersRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    final order = _order(id: 1);
    final line = order.items.single;

    final changed = await cubit.setLineQuantity(line, 5);
    await cubit.deleteLine(line);

    expect(changed, isTrue);
    expect(repository.setQuantityInputs.map((input) => input.quantity), [5, 0]);
  });

  test('cancels the selected open order', () async {
    final repository = _FakeOrdersRepository();
    final cubit = buildCubit(repository);
    addTearDown(cubit.close);
    addTearDown(repository.close);

    final order = _order(id: 7);

    final canceled = await cubit.cancelOrder(order);

    expect(canceled, isTrue);
    expect(repository.canceledOrderIds, [7]);
    expect(cubit.state.noticeMessage, 'BLP2026051901 dibatalkan.');
  });
}

OrderEntity _order({required int id}) {
  final now = DateTime(2026);

  return OrderEntity(
    id: id,
    orderNumber: 'BLP2026051901',
    orderType: OrderType.dineIn,
    customerName: 'Order Baru',
    status: OrderStatus.open,
    notes: null,
    totalAmount: 60000,
    createdAt: now,
    updatedAt: now,
    items: [
      OrderLineEntity(
        id: 1,
        orderId: id,
        menuItemId: 1,
        menuItemName: 'Bakmi Ayam',
        menuItemPrice: 30000,
        quantity: 2,
        notes: null,
        subtotal: 60000,
      ),
    ],
  );
}

class _FakeOrdersRepository implements OrdersRepository {
  final _ordersController = StreamController<List<OrderEntity>>.broadcast();
  final _menuItemsController =
      StreamController<List<OrderMenuItemEntity>>.broadcast();

  int nextOrderId = 1;
  final List<OrderItemQuantityInput> quantityInputs = [];
  final List<SetOrderItemQuantityInput> setQuantityInputs = [];
  final List<int> canceledOrderIds = [];

  void emitOrders(List<OrderEntity> orders) {
    _ordersController.add(orders);
  }

  void emitMenuItems(List<OrderMenuItemEntity> items) {
    _menuItemsController.add(items);
  }

  Future<void> close() async {
    await _ordersController.close();
    await _menuItemsController.close();
  }

  @override
  Stream<List<OrderEntity>> watchOpenOrders() {
    return _ordersController.stream;
  }

  @override
  Stream<List<OrderMenuItemEntity>> watchMenuItems() {
    return _menuItemsController.stream;
  }

  @override
  Future<int> createOrder() async {
    return nextOrderId;
  }

  @override
  Future<void> changeItemQuantity(OrderItemQuantityInput input) async {
    quantityInputs.add(input);
  }

  @override
  Future<void> setItemQuantity(SetOrderItemQuantityInput input) async {
    setQuantityInputs.add(input);
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    canceledOrderIds.add(orderId);
  }

  @override
  Future<void> confirmPayment(ConfirmOrderPaymentInput input) async {}
}

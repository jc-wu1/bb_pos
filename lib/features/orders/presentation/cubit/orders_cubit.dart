import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_quantity_input.dart';
import '../../domain/entities/order_line_entity.dart';
import '../../domain/entities/order_menu_category_entity.dart';
import '../../domain/entities/order_menu_item_entity.dart';
import '../../domain/entities/set_order_item_quantity_input.dart';
import '../../domain/usecase/cancel_order.dart';
import '../../domain/usecase/change_order_item_quantity.dart';
import '../../domain/usecase/create_order.dart';
import '../../domain/usecase/set_order_item_quantity.dart';
import '../../domain/usecase/watch_order_menu_items.dart';
import '../../domain/usecase/watch_orders.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required WatchOrders watchOrders,
    required WatchOrderMenuItems watchMenuItems,
    required CreateOrder createOrder,
    required ChangeOrderItemQuantity changeOrderItemQuantity,
    required SetOrderItemQuantity setOrderItemQuantity,
    required CancelOrder cancelOrder,
  }) : _watchOrders = watchOrders,
       _watchMenuItems = watchMenuItems,
       _createOrder = createOrder,
       _changeOrderItemQuantity = changeOrderItemQuantity,
       _setOrderItemQuantity = setOrderItemQuantity,
       _cancelOrder = cancelOrder,
       super(OrdersState.initial());

  final WatchOrders _watchOrders;
  final WatchOrderMenuItems _watchMenuItems;
  final CreateOrder _createOrder;
  final ChangeOrderItemQuantity _changeOrderItemQuantity;
  final SetOrderItemQuantity _setOrderItemQuantity;
  final CancelOrder _cancelOrder;

  StreamSubscription<List<OrderEntity>>? _ordersSubscription;
  StreamSubscription<List<OrderMenuItemEntity>>? _menuItemsSubscription;
  bool _isStarted = false;

  void load() {
    if (_isStarted) return;
    _isStarted = true;

    emit(state.copyWith(status: OrdersStatus.loading));

    _ordersSubscription = _watchOrders().listen(
      _onOrdersChanged,
      onError: (Object error, StackTrace stackTrace) {
        _emitStreamFailure();
      },
    );
    _menuItemsSubscription = _watchMenuItems().listen(
      _onMenuItemsChanged,
      onError: (Object error, StackTrace stackTrace) {
        _emitStreamFailure();
      },
    );
  }

  Future<void> retry() async {
    await _ordersSubscription?.cancel();
    await _menuItemsSubscription?.cancel();
    _ordersSubscription = null;
    _menuItemsSubscription = null;
    _isStarted = false;
    load();
  }

  void searchChanged(String query) {
    final nextQuery = query.trimLeft();
    emit(
      state.copyWith(
        searchQuery: nextQuery,
        visibleMenuItems: _filterMenuItems(
          items: state.menuItems,
          selectedCategory: state.selectedCategory,
          searchQuery: nextQuery,
        ),
      ),
    );
  }

  void clearSearch() {
    searchChanged('');
  }

  void selectCategory(OrderMenuCategoryEntity? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        visibleMenuItems: _filterMenuItems(
          items: state.menuItems,
          selectedCategory: category,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void selectOrder(OrderEntity order) {
    emit(
      state.copyWith(
        selectedOrderId: order.id,
        selectedOrder: order,
        selectedItemQuantities: _quantitiesFor(order),
      ),
    );
  }

  Future<void> createOrder() async {
    if (state.activeAction != OrdersAction.none) return;

    emit(
      state.copyWith(
        activeAction: OrdersAction.creating,
        clearErrorMessage: true,
      ),
    );

    try {
      final orderId = await _createOrder();
      final selectedOrder = _resolveSelectedOrder(
        selectedOrderId: orderId,
        orders: state.orders,
      );
      emit(
        state.copyWith(
          activeAction: OrdersAction.none,
          selectedOrderId: orderId,
          selectedOrder: selectedOrder,
          selectedItemQuantities: _quantitiesFor(selectedOrder),
        ),
      );
    } catch (_) {
      _emitActionFailure('Order gagal dibuat. Coba lagi.');
    }
  }

  Future<void> incrementMenu(OrderMenuItemEntity item) async {
    final selectedOrder = state.selectedOrder;
    if (selectedOrder == null || !item.isAvailable) return;

    await _changeQuantity(
      OrderItemQuantityInput.fromMenuItem(
        orderId: selectedOrder.id,
        item: item,
        delta: 1,
      ),
    );
  }

  Future<void> decrementMenu(OrderMenuItemEntity item) async {
    final selectedOrder = state.selectedOrder;
    if (selectedOrder == null) return;

    final quantity = state.selectedItemQuantities[item.id] ?? 0;
    if (quantity <= 0) return;

    await _changeQuantity(
      OrderItemQuantityInput.fromMenuItem(
        orderId: selectedOrder.id,
        item: item,
        delta: -1,
      ),
    );
  }

  Future<void> incrementLine(OrderLineEntity line) async {
    final item = _menuItemById(line.menuItemId);
    if (item == null || !item.isAvailable) return;

    await _changeQuantity(
      OrderItemQuantityInput.fromMenuItem(
        orderId: line.orderId,
        item: item,
        delta: 1,
      ),
    );
  }

  Future<void> decrementLine(OrderLineEntity line) async {
    await _changeQuantity(
      OrderItemQuantityInput.fromOrderLine(line: line, delta: -1),
    );
  }

  Future<bool> setLineQuantity(OrderLineEntity line, int quantity) async {
    if (quantity == line.quantity) return true;

    return _setQuantity(
      SetOrderItemQuantityInput(
        orderId: line.orderId,
        orderItemId: line.id,
        quantity: quantity,
      ),
    );
  }

  Future<void> deleteLine(OrderLineEntity line) async {
    await _setQuantity(
      SetOrderItemQuantityInput(
        orderId: line.orderId,
        orderItemId: line.id,
        quantity: 0,
      ),
    );
  }

  Future<bool> cancelOrder(OrderEntity order) async {
    if (state.activeAction != OrdersAction.none) return false;

    emit(
      state.copyWith(
        activeAction: OrdersAction.canceling,
        clearErrorMessage: true,
      ),
    );

    try {
      await _cancelOrder(order.id);
      emit(
        state.copyWith(
          activeAction: OrdersAction.none,
          noticeMessage: '${order.orderNumber} dibatalkan.',
          noticeSerial: state.noticeSerial + 1,
        ),
      );
      return true;
    } catch (_) {
      _emitActionFailure('Order gagal dibatalkan. Coba lagi.');
      return false;
    }
  }

  void selectPayment() {
    final selectedOrder = state.selectedOrder;
    if (selectedOrder == null || selectedOrder.items.isEmpty) return;

    emit(
      state.copyWith(
        clearErrorMessage: true,
        noticeMessage: 'Pilih pembayaran untuk ${selectedOrder.orderNumber}',
        noticeSerial: state.noticeSerial + 1,
      ),
    );
  }

  Future<void> _changeQuantity(OrderItemQuantityInput input) async {
    if (state.activeAction != OrdersAction.none) return;

    emit(
      state.copyWith(
        activeAction: OrdersAction.updating,
        clearErrorMessage: true,
      ),
    );

    try {
      await _changeOrderItemQuantity(input);
      emit(state.copyWith(activeAction: OrdersAction.none));
    } catch (_) {
      _emitActionFailure('Quantity order gagal diubah. Coba lagi.');
    }
  }

  Future<bool> _setQuantity(SetOrderItemQuantityInput input) async {
    if (state.activeAction != OrdersAction.none) return false;

    emit(
      state.copyWith(
        activeAction: OrdersAction.updating,
        clearErrorMessage: true,
      ),
    );

    try {
      await _setOrderItemQuantity(input);
      emit(state.copyWith(activeAction: OrdersAction.none));
      return true;
    } catch (_) {
      _emitActionFailure('Quantity order gagal diubah. Coba lagi.');
      return false;
    }
  }

  void _onOrdersChanged(List<OrderEntity> orders) {
    final safeOrders = List<OrderEntity>.unmodifiable(orders);
    final selectedOrder = _resolveSelectedOrder(
      selectedOrderId: state.selectedOrderId,
      orders: safeOrders,
    );

    emit(
      state.copyWith(
        status: OrdersStatus.ready,
        orders: safeOrders,
        selectedOrderId: selectedOrder?.id,
        selectedOrder: selectedOrder,
        selectedItemQuantities: _quantitiesFor(selectedOrder),
      ),
    );
  }

  void _onMenuItemsChanged(List<OrderMenuItemEntity> items) {
    final safeItems = List<OrderMenuItemEntity>.unmodifiable(items);
    final categories = _categoriesFor(safeItems);
    final selectedCategory = _resolveSelectedCategory(
      selectedCategory: state.selectedCategory,
      categories: categories,
    );

    emit(
      state.copyWith(
        status: state.status == OrdersStatus.loading && state.orders.isEmpty
            ? OrdersStatus.loading
            : OrdersStatus.ready,
        menuItems: safeItems,
        categories: categories,
        selectedCategory: selectedCategory,
        visibleMenuItems: _filterMenuItems(
          items: safeItems,
          selectedCategory: selectedCategory,
          searchQuery: state.searchQuery,
        ),
      ),
    );
  }

  void _emitStreamFailure() {
    emit(
      state.copyWith(
        status: OrdersStatus.failure,
        activeAction: OrdersAction.none,
        errorMessage: 'Data order gagal dimuat.',
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  void _emitActionFailure(String message) {
    emit(
      state.copyWith(
        activeAction: OrdersAction.none,
        errorMessage: message,
        errorSerial: state.errorSerial + 1,
      ),
    );
  }

  OrderEntity? _resolveSelectedOrder({
    required int? selectedOrderId,
    required List<OrderEntity> orders,
  }) {
    if (orders.isEmpty) return null;

    if (selectedOrderId != null) {
      for (final order in orders) {
        if (order.id == selectedOrderId) return order;
      }
    }

    return orders.first;
  }

  OrderMenuCategoryEntity? _resolveSelectedCategory({
    required OrderMenuCategoryEntity? selectedCategory,
    required List<OrderMenuCategoryEntity> categories,
  }) {
    if (selectedCategory == null) return null;

    for (final category in categories) {
      if (category.id == selectedCategory.id) return category;
    }

    return null;
  }

  Map<int, int> _quantitiesFor(OrderEntity? order) {
    if (order == null) return const {};

    return Map<int, int>.unmodifiable({
      for (final line in order.items) line.menuItemId: line.quantity,
    });
  }

  List<OrderMenuCategoryEntity> _categoriesFor(
    List<OrderMenuItemEntity> items,
  ) {
    final categoriesById = <int, OrderMenuCategoryEntity>{};
    for (final item in items) {
      categoriesById[item.category.id] = item.category;
    }

    final categories = categoriesById.values.toList()..sort(_compareCategories);
    return List.unmodifiable(categories);
  }

  List<OrderMenuItemEntity> _filterMenuItems({
    required List<OrderMenuItemEntity> items,
    required OrderMenuCategoryEntity? selectedCategory,
    required String searchQuery,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = items.where((item) {
      final isSameCategory =
          selectedCategory == null || item.category.id == selectedCategory.id;
      if (!isSameCategory) return false;
      if (query.isEmpty) return true;

      return item.name.toLowerCase().contains(query) ||
          item.category.name.toLowerCase().contains(query);
    }).toList()..sort(_compareMenuItems);

    return List.unmodifiable(filtered);
  }

  OrderMenuItemEntity? _menuItemById(int id) {
    for (final item in state.menuItems) {
      if (item.id == id) return item;
    }

    return null;
  }

  int _compareCategories(
    OrderMenuCategoryEntity first,
    OrderMenuCategoryEntity second,
  ) {
    final orderComparison = first.displayOrder.compareTo(second.displayOrder);
    if (orderComparison != 0) return orderComparison;

    return first.name.compareTo(second.name);
  }

  int _compareMenuItems(OrderMenuItemEntity first, OrderMenuItemEntity second) {
    final categoryComparison = first.category.displayOrder.compareTo(
      second.category.displayOrder,
    );
    if (categoryComparison != 0) return categoryComparison;

    final orderComparison = first.displayOrder.compareTo(second.displayOrder);
    if (orderComparison != 0) return orderComparison;

    return first.name.compareTo(second.name);
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    await _menuItemsSubscription?.cancel();
    return super.close();
  }
}

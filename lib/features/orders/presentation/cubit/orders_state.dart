part of 'orders_cubit.dart';

const Object _stateFieldNotSet = Object();

enum OrdersStatus { initial, loading, ready, failure }

enum OrdersAction { none, creating, updating, canceling }

class OrdersState extends Equatable {
  const OrdersState({
    required this.status,
    required this.activeAction,
    required this.orders,
    required this.selectedOrderId,
    required this.selectedOrder,
    required this.menuItems,
    required this.visibleMenuItems,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    required this.selectedItemQuantities,
    required this.errorMessage,
    required this.errorSerial,
    required this.noticeMessage,
    required this.noticeSerial,
  });

  factory OrdersState.initial() {
    return const OrdersState(
      status: OrdersStatus.initial,
      activeAction: OrdersAction.none,
      orders: [],
      selectedOrderId: null,
      selectedOrder: null,
      menuItems: [],
      visibleMenuItems: [],
      categories: [],
      selectedCategory: null,
      searchQuery: '',
      selectedItemQuantities: {},
      errorMessage: null,
      errorSerial: 0,
      noticeMessage: null,
      noticeSerial: 0,
    );
  }

  final OrdersStatus status;
  final OrdersAction activeAction;
  final List<OrderEntity> orders;
  final int? selectedOrderId;
  final OrderEntity? selectedOrder;
  final List<OrderMenuItemEntity> menuItems;
  final List<OrderMenuItemEntity> visibleMenuItems;
  final List<OrderMenuCategoryEntity> categories;
  final OrderMenuCategoryEntity? selectedCategory;
  final String searchQuery;
  final Map<int, int> selectedItemQuantities;
  final String? errorMessage;
  final int errorSerial;
  final String? noticeMessage;
  final int noticeSerial;

  bool get isInitialLoading {
    return status == OrdersStatus.loading &&
        orders.isEmpty &&
        menuItems.isEmpty;
  }

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersAction? activeAction,
    List<OrderEntity>? orders,
    Object? selectedOrderId = _stateFieldNotSet,
    Object? selectedOrder = _stateFieldNotSet,
    List<OrderMenuItemEntity>? menuItems,
    List<OrderMenuItemEntity>? visibleMenuItems,
    List<OrderMenuCategoryEntity>? categories,
    Object? selectedCategory = _stateFieldNotSet,
    String? searchQuery,
    Map<int, int>? selectedItemQuantities,
    Object? errorMessage = _stateFieldNotSet,
    bool clearErrorMessage = false,
    int? errorSerial,
    Object? noticeMessage = _stateFieldNotSet,
    int? noticeSerial,
  }) {
    final resolvedErrorMessage = clearErrorMessage
        ? null
        : identical(errorMessage, _stateFieldNotSet)
        ? this.errorMessage
        : errorMessage as String?;

    return OrdersState(
      status: status ?? this.status,
      activeAction: activeAction ?? this.activeAction,
      orders: orders ?? this.orders,
      selectedOrderId: identical(selectedOrderId, _stateFieldNotSet)
          ? this.selectedOrderId
          : selectedOrderId as int?,
      selectedOrder: identical(selectedOrder, _stateFieldNotSet)
          ? this.selectedOrder
          : selectedOrder as OrderEntity?,
      menuItems: menuItems ?? this.menuItems,
      visibleMenuItems: visibleMenuItems ?? this.visibleMenuItems,
      categories: categories ?? this.categories,
      selectedCategory: identical(selectedCategory, _stateFieldNotSet)
          ? this.selectedCategory
          : selectedCategory as OrderMenuCategoryEntity?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedItemQuantities:
          selectedItemQuantities ?? this.selectedItemQuantities,
      errorMessage: resolvedErrorMessage,
      errorSerial: errorSerial ?? this.errorSerial,
      noticeMessage: identical(noticeMessage, _stateFieldNotSet)
          ? this.noticeMessage
          : noticeMessage as String?,
      noticeSerial: noticeSerial ?? this.noticeSerial,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      activeAction,
      orders,
      selectedOrderId,
      selectedOrder,
      menuItems,
      visibleMenuItems,
      categories,
      selectedCategory,
      searchQuery,
      selectedItemQuantities,
      errorMessage,
      errorSerial,
      noticeMessage,
      noticeSerial,
    ];
  }
}

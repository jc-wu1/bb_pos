import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/entities/order_entity.dart';
import '../domain/entities/order_line_entity.dart';
import '../domain/entities/order_menu_category_entity.dart';
import '../domain/entities/order_menu_item_entity.dart';
import '../domain/entities/order_status.dart';
import 'cubit/orders_cubit.dart';

const Color _openOrderBackground = Color(0xfffff1d6);
const Color _openOrderForeground = Color(0xff7a4b00);
const Color _selectedOrderBackground = Color(0xffdff8e9);
const Color _selectedOrderForeground = Color(0xff14532d);
const Color _canceledOrderBackground = Color(0xffffdad6);
const Color _canceledOrderForeground = Color(0xff93000a);
const Color _menuUnavailableColor = Color(0xffdc4a2d);

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersCubit>()..load(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) {
        return (previous.errorSerial != current.errorSerial &&
                current.errorMessage != null) ||
            (previous.noticeSerial != current.noticeSerial &&
                current.noticeMessage != null);
      },
      listener: (context, state) {
        final message = state.errorMessage ?? state.noticeMessage;
        if (message == null) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;
              final horizontalPadding = isCompact ? 14.0 : 20.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderBar(
                      isCreating: state.activeAction == OrdersAction.creating,
                      onCreateOrder: context.read<OrdersCubit>().createOrder,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _OrdersContent(
                        state: state,
                        isCompact: isCompact,
                        searchController: _searchController,
                        onRetry: context.read<OrdersCubit>().retry,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.state,
    required this.isCompact,
    required this.searchController,
    required this.onRetry,
  });

  final OrdersState state;
  final bool isCompact;
  final TextEditingController searchController;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const _LoadingOrdersState();
    }

    if (state.status == OrdersStatus.failure &&
        state.orders.isEmpty &&
        state.menuItems.isEmpty) {
      return _ErrorOrdersState(onRetry: onRetry);
    }

    return _OrderWorkspace(
      isCompact: isCompact,
      orders: state.orders,
      selectedOrderId: state.selectedOrderId,
      selectedOrder: state.selectedOrder,
      menuItems: state.visibleMenuItems,
      categories: state.categories,
      selectedCategory: state.selectedCategory,
      searchController: searchController,
      searchQuery: state.searchQuery,
      selectedItemQuantities: state.selectedItemQuantities,
      onSearchChanged: context.read<OrdersCubit>().searchChanged,
      onClearSearch: () {
        searchController.clear();
        context.read<OrdersCubit>().clearSearch();
      },
      onCategoryChanged: context.read<OrdersCubit>().selectCategory,
      onSelectOrder: context.read<OrdersCubit>().selectOrder,
      onSelectPayment: (order) => context.push('/orders/summary', extra: order),
      onIncrementMenu: context.read<OrdersCubit>().incrementMenu,
      onDecrementMenu: context.read<OrdersCubit>().decrementMenu,
      onIncrementLine: context.read<OrdersCubit>().incrementLine,
      onDecrementLine: context.read<OrdersCubit>().decrementLine,
      onEditLineQuantity: (line) => _showQuantityDialog(context, line),
      onDeleteLine: context.read<OrdersCubit>().deleteLine,
      onCancelOrder: (order) => _confirmCancelOrder(context, order),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.isCreating, required this.onCreateOrder});

  final bool isCreating;
  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final title = Text(
          'Orders',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        );
        final button = ElevatedButton.icon(
          onPressed: isCreating ? null : onCreateOrder,
          icon: const Icon(Icons.add),
          label: const Text('Buat Order'),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 10), button],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.selectedOrderId,
    required this.onSelected,
  });

  final List<OrderEntity> orders;
  final int? selectedOrderId;
  final ValueChanged<OrderEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyOrdersState();
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final order = orders[index];
        return SizedBox(
          width: 216,
          child: _OrderCard(
            order: order,
            isSelected: order.id == selectedOrderId,
            onTap: () => onSelected(order),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final OrderEntity order;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCanceled = order.status == OrderStatus.canceled;
    final backgroundColor = isSelected
        ? isCanceled
              ? _canceledOrderBackground
              : _selectedOrderBackground
        : colorScheme.surfaceContainerLowest;
    final foregroundColor = isSelected
        ? isCanceled
              ? _canceledOrderForeground
              : _selectedOrderForeground
        : colorScheme.onSurface;

    return AppSurfaceCard(
      onTap: onTap,
      color: backgroundColor,
      borderColor: isSelected ? foregroundColor : null,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 18,
                    color: foregroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 18, color: foregroundColor),
            ],
          ),
          const Spacer(),
          Text(
            order.customerLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              StatusPill(status: _statusForOrder(order.status)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${order.itemCount} item - ${_formatTime(order.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.68),
                  ),
                ),
              ),
              Text(
                _formatCurrency(order.totalAmount),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderWorkspace extends StatelessWidget {
  const _OrderWorkspace({
    required this.isCompact,
    required this.orders,
    required this.selectedOrderId,
    required this.selectedOrder,
    required this.menuItems,
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.searchQuery,
    required this.selectedItemQuantities,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryChanged,
    required this.onSelectOrder,
    required this.onSelectPayment,
    required this.onIncrementMenu,
    required this.onDecrementMenu,
    required this.onIncrementLine,
    required this.onDecrementLine,
    required this.onEditLineQuantity,
    required this.onDeleteLine,
    required this.onCancelOrder,
  });

  final bool isCompact;
  final List<OrderEntity> orders;
  final int? selectedOrderId;
  final OrderEntity? selectedOrder;
  final List<OrderMenuItemEntity> menuItems;
  final List<OrderMenuCategoryEntity> categories;
  final OrderMenuCategoryEntity? selectedCategory;
  final TextEditingController searchController;
  final String searchQuery;
  final Map<int, int> selectedItemQuantities;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<OrderMenuCategoryEntity?> onCategoryChanged;
  final ValueChanged<OrderEntity> onSelectOrder;
  final ValueChanged<OrderEntity> onSelectPayment;
  final ValueChanged<OrderMenuItemEntity> onIncrementMenu;
  final ValueChanged<OrderMenuItemEntity> onDecrementMenu;
  final ValueChanged<OrderLineEntity> onIncrementLine;
  final ValueChanged<OrderLineEntity> onDecrementLine;
  final ValueChanged<OrderLineEntity> onEditLineQuantity;
  final ValueChanged<OrderLineEntity> onDeleteLine;
  final ValueChanged<OrderEntity> onCancelOrder;

  @override
  Widget build(BuildContext context) {
    final isOrderReadOnly = selectedOrder?.status == OrderStatus.canceled;
    final orderList = _OrderList(
      orders: orders,
      selectedOrderId: selectedOrderId,
      onSelected: onSelectOrder,
    );
    final orderPanel = _SelectedOrderPanel(
      order: selectedOrder,
      isReadOnly: isOrderReadOnly,
      onSelectPayment: onSelectPayment,
      onIncrementLine: onIncrementLine,
      onDecrementLine: onDecrementLine,
      onEditLineQuantity: onEditLineQuantity,
      onDeleteLine: onDeleteLine,
      onCancelOrder: onCancelOrder,
    );
    final menuCatalog = _MenuCatalog(
      items: menuItems,
      selectedOrder: selectedOrder,
      isOrderReadOnly: isOrderReadOnly,
      categories: categories,
      selectedCategory: selectedCategory,
      searchController: searchController,
      searchQuery: searchQuery,
      selectedItemQuantities: selectedItemQuantities,
      onSearchChanged: onSearchChanged,
      onClearSearch: onClearSearch,
      onCategoryChanged: onCategoryChanged,
      onIncrementMenu: onIncrementMenu,
      onDecrementMenu: onDecrementMenu,
      onEditLineQuantity: onEditLineQuantity,
    );

    if (isCompact) {
      return Column(
        children: [
          SizedBox(height: 108, child: orderList),
          const SizedBox(height: 12),
          SizedBox(height: 238, child: orderPanel),
          const SizedBox(height: 12),
          Expanded(child: menuCatalog),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 7, child: menuCatalog),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              SizedBox(height: 116, child: orderList),
              const SizedBox(height: 12),
              Expanded(child: orderPanel),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedOrderPanel extends StatelessWidget {
  const _SelectedOrderPanel({
    required this.order,
    required this.isReadOnly,
    required this.onSelectPayment,
    required this.onIncrementLine,
    required this.onDecrementLine,
    required this.onEditLineQuantity,
    required this.onDeleteLine,
    required this.onCancelOrder,
  });

  final OrderEntity? order;
  final bool isReadOnly;
  final ValueChanged<OrderEntity> onSelectPayment;
  final ValueChanged<OrderLineEntity> onIncrementLine;
  final ValueChanged<OrderLineEntity> onDecrementLine;
  final ValueChanged<OrderLineEntity> onEditLineQuantity;
  final ValueChanged<OrderLineEntity> onDeleteLine;
  final ValueChanged<OrderEntity> onCancelOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = this.order;
    final canSelectPayment =
        order != null && !isReadOnly && order.items.isNotEmpty;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _openOrderBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(
                      Icons.room_service_outlined,
                      color: _openOrderForeground,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.orderNumber ?? 'Order',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order == null
                            ? 'Belum ada order terpilih'
                            : isReadOnly
                            ? '${order.customerLabel} - read only'
                            : '${order.customerLabel} - ${order.itemCount} item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order != null) ...[
                  const SizedBox(width: 8),
                  StatusPill(status: _statusForOrder(order.status)),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          if (isReadOnly) const _ReadOnlyOrderBanner(),
          Expanded(
            child: order == null || order.items.isEmpty
                ? const _EmptySelectedOrderState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: order.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = order.items[index];
                      return _SelectedOrderLine(
                        line: line,
                        onIncrement: isReadOnly
                            ? null
                            : () => onIncrementLine(line),
                        onDecrement: isReadOnly
                            ? null
                            : () => onDecrementLine(line),
                        onEditQuantity: isReadOnly
                            ? null
                            : () => onEditLineQuantity(line),
                        onDelete: isReadOnly ? null : () => onDeleteLine(line),
                      );
                    },
                  ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Subtotal',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatCurrency(order?.totalAmount ?? 0),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: order == null || isReadOnly
                              ? null
                              : () => onCancelOrder(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded),
                          label: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: canSelectPayment
                              ? () => onSelectPayment(order)
                              : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('Lanjut'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedOrderLine extends StatelessWidget {
  const _SelectedOrderLine({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEditQuantity,
    required this.onDelete,
  });

  final OrderLineEntity line;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onEditQuantity;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.menuItemName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCurrency(line.menuItemPrice)} / porsi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(line.subtotal),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuantityStepper(
                    quantity: line.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                    onQuantityTap: onEditQuantity,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus item',
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    fixedSize: const Size.square(32),
                    minimumSize: const Size.square(32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyOrderBanner extends StatelessWidget {
  const _ReadOnlyOrderBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Order canceled hanya bisa dilihat.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showQuantityDialog(
  BuildContext context,
  OrderLineEntity line,
) async {
  final cubit = context.read<OrdersCubit>();

  await showDialog<void>(
    context: context,
    builder: (_) => _QuantityDialog(cubit: cubit, line: line),
  );
}

class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({required this.cubit, required this.line});

  final OrdersCubit cubit;
  final OrderLineEntity line;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.line.quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 1) {
      setState(() {
        _errorText = 'Quantity minimal 1.';
      });
      return;
    }

    final success = await widget.cubit.setLineQuantity(widget.line, value);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Kuantiti'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Quantity',
          prefixIcon: const Icon(Icons.edit_outlined),
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

Future<void> _confirmCancelOrder(
  BuildContext context,
  OrderEntity order,
) async {
  final cubit = context.read<OrdersCubit>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
        title: const Text('Batalkan order?'),
        content: Text(
          '${order.orderNumber} - ${order.customerLabel} akan ditandai canceled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tetap Open'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await cubit.cancelOrder(order);
              if (success && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Batalkan Order'),
          ),
        ],
      );
    },
  );
}

class _MenuCatalog extends StatelessWidget {
  const _MenuCatalog({
    required this.items,
    required this.selectedOrder,
    required this.isOrderReadOnly,
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.searchQuery,
    required this.selectedItemQuantities,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryChanged,
    required this.onIncrementMenu,
    required this.onDecrementMenu,
    required this.onEditLineQuantity,
  });

  final List<OrderMenuItemEntity> items;
  final OrderEntity? selectedOrder;
  final bool isOrderReadOnly;
  final List<OrderMenuCategoryEntity> categories;
  final OrderMenuCategoryEntity? selectedCategory;
  final TextEditingController searchController;
  final String searchQuery;
  final Map<int, int> selectedItemQuantities;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<OrderMenuCategoryEntity?> onCategoryChanged;
  final ValueChanged<OrderMenuItemEntity> onIncrementMenu;
  final ValueChanged<OrderMenuItemEntity> onDecrementMenu;
  final ValueChanged<OrderLineEntity> onEditLineQuantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSelectedOrder = selectedOrder != null;
    final hasWritableOrder = hasSelectedOrder && !isOrderReadOnly;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menu',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!hasSelectedOrder)
                      Text(
                        'Pilih order',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (isOrderReadOnly)
                      Text(
                        'Read only',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: appFieldDecoration(
                    context,
                    label: 'Cari Menu',
                    hint: 'Cari nama atau kategori',
                    prefixIcon: Icons.search,
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                _CategoryFilter(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onChanged: onCategoryChanged,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: items.isEmpty
                ? _EmptyMenuState(searchQuery: searchQuery)
                : _MenuGrid(
                    items: items,
                    selectedOrder: selectedOrder,
                    hasWritableOrder: hasWritableOrder,
                    selectedItemQuantities: selectedItemQuantities,
                    onIncrementMenu: onIncrementMenu,
                    onDecrementMenu: onDecrementMenu,
                    onEditLineQuantity: onEditLineQuantity,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<OrderMenuCategoryEntity> categories;
  final OrderMenuCategoryEntity? selectedCategory;
  final ValueChanged<OrderMenuCategoryEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chips = <OrderMenuCategoryEntity?>[null, ...categories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in chips) ...[
            FilterChip(
              selected: selectedCategory?.id == category?.id,
              showCheckmark: false,
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: selectedCategory?.id == category?.id
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              avatar: category == null
                  ? null
                  : Icon(_iconForCategory(category.name), size: 18),
              label: Text(category?.name ?? 'Semua'),
              labelStyle: TextStyle(
                color: selectedCategory?.id == category?.id
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: selectedCategory?.id == category?.id
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
              onSelected: (_) => onChanged(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.items,
    required this.selectedOrder,
    required this.hasWritableOrder,
    required this.selectedItemQuantities,
    required this.onIncrementMenu,
    required this.onDecrementMenu,
    required this.onEditLineQuantity,
  });

  final List<OrderMenuItemEntity> items;
  final OrderEntity? selectedOrder;
  final bool hasWritableOrder;
  final Map<int, int> selectedItemQuantities;
  final ValueChanged<OrderMenuItemEntity> onIncrementMenu;
  final ValueChanged<OrderMenuItemEntity> onDecrementMenu;
  final ValueChanged<OrderLineEntity> onEditLineQuantity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineByMenuItemId = <int, OrderLineEntity>{
          for (final line in selectedOrder?.items ?? const <OrderLineEntity>[])
            line.menuItemId: line,
        };
        const spacing = 12.0;
        final crossAxisCount = constraints.maxWidth < 430
            ? 1
            : constraints.maxWidth < 700
            ? 2
            : ((constraints.maxWidth + spacing) / (220 + spacing))
                  .floor()
                  .clamp(3, 8)
                  .toInt();
        final childAspectRatio = constraints.maxWidth < 700 ? 2 / 3 : 0.76;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final quantity = selectedItemQuantities[item.id] ?? 0;
            final line = lineByMenuItemId[item.id];
            return _MenuItemCard(
              item: item,
              quantity: quantity,
              canAdd: hasWritableOrder && item.isAvailable,
              onIncrement: () => onIncrementMenu(item),
              onDecrement: hasWritableOrder
                  ? () => onDecrementMenu(item)
                  : null,
              onQuantityTap: line == null || !hasWritableOrder
                  ? null
                  : () => onEditLineQuantity(line),
            );
          },
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.canAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityTap,
  });

  final OrderMenuItemEntity item;
  final int quantity;
  final bool canAdd;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: item.isAvailable ? 1 : 0.62,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MenuImagePlaceholder(
                    categoryName: item.category.name,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _QuantityStepper(
                        quantity: quantity,
                        onIncrement: canAdd ? onIncrement : null,
                        onDecrement: quantity > 0 ? onDecrement : null,
                        onQuantityTap: onQuantityTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!item.isAvailable)
              const Positioned(top: 10, right: 10, child: _UnavailableBadge()),
          ],
        ),
      ),
    );
  }
}

class _MenuImagePlaceholder extends StatelessWidget {
  const _MenuImagePlaceholder({required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              _iconForCategory(categoryName),
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnavailableBadge extends StatelessWidget {
  const _UnavailableBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _menuUnavailableColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Habis',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityTap,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onQuantityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canEdit = onQuantityTap != null;
    final quantityContent = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 32,
      constraints: const BoxConstraints(minWidth: 42),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: canEdit
            ? colorScheme.primaryContainer.withValues(alpha: 0.9)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canEdit ? colorScheme.primary : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: canEdit ? colorScheme.onPrimaryContainer : null,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.edit_outlined,
              size: 12,
              color: colorScheme.onPrimaryContainer,
            ),
          ],
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        IconButton.filledTonal(
          tooltip: 'Kurangi quantity',
          onPressed: onDecrement,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(32),
            minimumSize: const Size.square(32),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.remove, size: 16),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: canEdit
              ? Tooltip(
                  message: 'Ubah Kuantiti',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onQuantityTap,
                      borderRadius: BorderRadius.circular(8),
                      child: quantityContent,
                    ),
                  ),
                )
              : quantityContent,
        ),
        IconButton.filled(
          tooltip: 'Tambah quantity',
          onPressed: onIncrement,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(32),
            minimumSize: const Size.square(32),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.add, size: 16),
        ),
      ],
    );
  }
}

class _LoadingOrdersState extends StatelessWidget {
  const _LoadingOrdersState();

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorOrdersState extends StatelessWidget {
  const _ErrorOrdersState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 44),
            const SizedBox(height: 10),
            Text(
              'Data order gagal dimuat',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Center(
        child: Text(
          'Belum ada order',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptySelectedOrderState extends StatelessWidget {
  const _EmptySelectedOrderState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_shopping_cart_outlined,
              size: 44,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada menu dipilih',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 46,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              searchQuery.trim().isEmpty
                  ? 'Menu tidak tersedia di kategori ini'
                  : 'Menu tidak ditemukan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForCategory(String categoryName) {
  return switch (categoryName.toLowerCase()) {
    'makanan' => Icons.ramen_dining_outlined,
    'minuman' => Icons.local_cafe_outlined,
    'side dish' => Icons.tapas_outlined,
    _ => Icons.restaurant_menu_outlined,
  };
}

String _formatCurrency(int value) {
  return 'Rp ${NumberFormat.decimalPattern('id_ID').format(value)}';
}

String _formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

StatusPillStatus _statusForOrder(OrderStatus status) {
  return switch (status) {
    OrderStatus.open => StatusPillStatus.open,
    OrderStatus.completed => StatusPillStatus.completed,
    OrderStatus.canceled => StatusPillStatus.canceled,
  };
}

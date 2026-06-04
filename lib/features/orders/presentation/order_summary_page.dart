import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/widgets.dart';
import '../domain/entities/order_entity.dart';
import '../domain/entities/order_line_entity.dart';
import '../domain/entities/order_payment_method.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key, required this.order});

  final OrderEntity? order;

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  OrderPaymentMethod _selectedPaymentMethod = OrderPaymentMethod.cash;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/orders');
  }

  void _openSelectedPayment(BuildContext context) {
    final order = widget.order;
    if (order == null || order.items.isEmpty) return;

    final path = switch (_selectedPaymentMethod) {
      OrderPaymentMethod.cash => '/orders/cash-payment',
      OrderPaymentMethod.qris => '/orders/qris-payment',
    };

    context.push(path, extra: order);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 840 ? 14.0 : 22.0;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OrderSummaryHeader(
                      order: order,
                      onBack: () => _goBack(context),
                    ),
                    const SizedBox(height: 14),
                    if (order == null)
                      Expanded(
                        child: _MissingOrderState(
                          onBack: () => _goBack(context),
                        ),
                      )
                    else
                      Expanded(
                        child: _OrderSummaryBody(
                          order: order,
                          selectedPaymentMethod: _selectedPaymentMethod,
                          onPaymentMethodChanged: (method) {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                          onConfirmPaymentPressed: () =>
                              _openSelectedPayment(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderSummaryHeader extends StatelessWidget {
  const _OrderSummaryHeader({required this.order, required this.onBack});

  final OrderEntity? order;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = this.order;

    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Kembali',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order == null
                    ? 'Order belum tersedia'
                    : '${order.orderNumber} - ${order.customerLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryBody extends StatelessWidget {
  const _OrderSummaryBody({
    required this.order,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.onConfirmPaymentPressed,
  });

  final OrderEntity order;
  final OrderPaymentMethod selectedPaymentMethod;
  final ValueChanged<OrderPaymentMethod> onPaymentMethodChanged;
  final VoidCallback onConfirmPaymentPressed;

  @override
  Widget build(BuildContext context) {
    final orderPanel = _OrderedItemsPanel(order: order);
    final paymentPanel = _PaymentMethodPanel(
      selectedPaymentMethod: selectedPaymentMethod,
      onPaymentMethodChanged: onPaymentMethodChanged,
      onConfirmPaymentPressed: onConfirmPaymentPressed,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 7, child: orderPanel),
        const SizedBox(width: 14),
        Expanded(flex: 4, child: paymentPanel),
      ],
    );
  }
}

class _OrderedItemsPanel extends StatelessWidget {
  const _OrderedItemsPanel({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemList = ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: order.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _OrderedItemTile(line: order.items[index]);
      },
    );

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Order',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.itemCount} item dipesan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(child: itemList),
          _TotalsFooter(total: order.totalAmount),
        ],
      ),
    );
  }
}

class _OrderedItemTile extends StatelessWidget {
  const _OrderedItemTile({required this.line});

  final OrderLineEntity line;

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
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox.square(
                dimension: 42,
                child: Center(
                  child: Text(
                    '${line.quantity}x',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                    _formatCurrency(line.menuItemPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatCurrency(line.subtotal),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsFooter extends StatelessWidget {
  const _TotalsFooter({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AmountRow(label: 'Total', value: total, isEmphasized: true),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final int value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                (isEmphasized
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleSmall)
                    ?.copyWith(
                      color: isEmphasized ? null : colorScheme.onSurfaceVariant,
                      fontWeight: isEmphasized
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style:
              (isEmphasized
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    color: isEmphasized ? colorScheme.primary : null,
                    fontWeight: FontWeight.w900,
                  ),
        ),
      ],
    );
  }
}

class _PaymentMethodPanel extends StatelessWidget {
  const _PaymentMethodPanel({
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.onConfirmPaymentPressed,
  });

  final OrderPaymentMethod selectedPaymentMethod;
  final ValueChanged<OrderPaymentMethod> onPaymentMethodChanged;
  final VoidCallback onConfirmPaymentPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.payments_outlined,
                      size: 22,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select payment method',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _PaymentMethodTile(
                  title: 'Cash',
                  subtitle: 'Pembayaran tunai di kasir',
                  icon: Icons.attach_money,
                  selected: selectedPaymentMethod == OrderPaymentMethod.cash,
                  onTap: () => onPaymentMethodChanged(OrderPaymentMethod.cash),
                ),
                const SizedBox(height: 10),
                _PaymentMethodTile(
                  title: 'QRIS',
                  subtitle: 'Scan kode QR untuk pembayaran digital',
                  icon: Icons.qr_code_2_outlined,
                  selected: selectedPaymentMethod == OrderPaymentMethod.qris,
                  onTap: () => onPaymentMethodChanged(OrderPaymentMethod.qris),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SelectedPaymentSummary(method: selectedPaymentMethod),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onConfirmPaymentPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedPaymentMethod == OrderPaymentMethod.cash
                          ? 'Lanjut ke Pembayaran Cash'
                          : 'Lanjut ke Pembayaran QRIS',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final backgroundColor = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.5)
        : colorScheme.surfaceContainerLow;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPaymentSummary extends StatelessWidget {
  const _SelectedPaymentSummary({required this.method});

  final OrderPaymentMethod method;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Metode terpilih',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              method.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingOrderState extends StatelessWidget {
  const _MissingOrderState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              'Order tidak ditemukan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCurrency(int value) {
  return 'Rp ${NumberFormat.decimalPattern('id_ID').format(value)}';
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/widgets.dart';
import '../../orders/domain/entities/order_entity.dart';
import '../../orders/domain/entities/order_line_entity.dart';
import 'cubit/cash_payment_cubit.dart';

class CashPaymentPage extends StatelessWidget {
  const CashPaymentPage({super.key, required this.order});

  final OrderEntity? order;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CashPaymentCubit>(param1: order),
      child: const _CashPaymentView(),
    );
  }
}

class _CashPaymentView extends StatelessWidget {
  const _CashPaymentView();

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CashPaymentCubit, CashPaymentState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CashPaymentStatus.completed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.noticeMessage ?? 'Pembayaran selesai.'),
            ),
          );
          context.go('/orders');
          return;
        }

        if (state.status == CashPaymentStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Pembayaran gagal diselesaikan.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final order = state.order;

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 840
                  ? 14.0
                  : 22.0;

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
                        _CashPaymentHeader(
                          order: order,
                          onBack: () => _goBack(context),
                        ),
                        const SizedBox(height: 14),
                        if (order == null)
                          Expanded(
                            child: _MissingCashPaymentState(
                              onBack: () => _goBack(context),
                            ),
                          )
                        else
                          Expanded(
                            child: _CashPaymentBody(
                              order: order,
                              isCompact: constraints.maxWidth < 900,
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
      },
    );
  }
}

class _CashPaymentHeader extends StatelessWidget {
  const _CashPaymentHeader({required this.order, required this.onBack});

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
                'Cash Payment',
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

class _CashPaymentBody extends StatelessWidget {
  const _CashPaymentBody({required this.order, required this.isCompact});

  final OrderEntity order;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final paymentPanel = _CashTenderPanel(order: order);
    final detailPanel = _CashOrderDetailPanel(
      order: order,
      shrinkWrapItems: isCompact,
    );

    if (isCompact) {
      return ListView(
        children: [detailPanel, const SizedBox(height: 14), paymentPanel],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: detailPanel),
        const SizedBox(width: 14),
        Expanded(flex: 4, child: paymentPanel),
      ],
    );
  }
}

class _CashTenderPanel extends StatelessWidget {
  const _CashTenderPanel({required this.order});

  final OrderEntity order;

  Future<void> _showFinishConfirmation(
    BuildContext context,
    CashPaymentState state,
  ) async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogAmountRow(
                label: 'Total Tagihan',
                value: order.totalAmount,
              ),
              const SizedBox(height: 8),
              _DialogAmountRow(
                label: 'Uang Diterima',
                value: state.receivedAmount,
              ),
              const SizedBox(height: 8),
              _DialogAmountRow(
                label: 'Kembalian',
                value: state.displayChangeAmount,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );

    if (shouldFinish == true && context.mounted) {
      await context.read<CashPaymentCubit>().completePayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CashPaymentCubit, CashPaymentState>(
      builder: (context, state) {
        final cubit = context.read<CashPaymentCubit>();
        final shortfallAmount = state.shortfallAmount;
        final amountErrorText = shortfallAmount == null
            ? null
            : 'Uang diterima kurang ${_formatCurrency(shortfallAmount)}';

        return AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.point_of_sale_outlined,
                          size: 22,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pembayaran Tunai',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TotalDueCard(total: order.totalAmount),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CashDisplay(
                        label: 'Uang Diterima',
                        value: _formatCurrency(state.receivedAmount),
                        helperText: amountErrorText ?? 'Nominal cash',
                        isError: amountErrorText != null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CashDisplay(
                        label: 'Kembalian',
                        value: _formatCurrency(state.displayChangeAmount),
                        helperText: state.hasCalculatedChange
                            ? 'Siap diselesaikan'
                            : 'Hitung terlebih dahulu',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickAmountChip(
                      label: 'Pas',
                      value: order.totalAmount,
                      onPressed: state.isCompletingPayment
                          ? null
                          : () => cubit.setReceivedAmount(order.totalAmount),
                    ),
                    for (final amount in state.quickAmounts)
                      _QuickAmountChip(
                        label: _formatCurrency(amount),
                        onPressed: state.isCompletingPayment
                            ? null
                            : () => cubit.setReceivedAmount(amount),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _KeypadPreview(
                  onKeyPressed: cubit.appendKey,
                  onDelete: cubit.deleteKey,
                ),
                const SizedBox(height: 10),
                if (state.hasCalculatedChange)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.isCompletingPayment
                              ? null
                              : cubit.resetPayment,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.isCompletingPayment
                              ? null
                              : () => _showFinishConfirmation(context, state),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: state.isCompletingPayment
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              state.isCompletingPayment
                                  ? 'Memproses...'
                                  : 'Selesaikan Pembayaran',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    onPressed:
                        state.receivedAmount == 0 || state.isCompletingPayment
                        ? null
                        : cubit.calculateChange,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Hitung'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogAmountRow extends StatelessWidget {
  const _DialogAmountRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TotalDueCard extends StatelessWidget {
  const _TotalDueCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Tagihan',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatCurrency(total),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineMedium?.copyWith(
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

class _CashDisplay extends StatelessWidget {
  const _CashDisplay({
    required this.label,
    required this.value,
    required this.helperText,
    this.isError = false,
  });

  final String label;
  final String value;
  final String helperText;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? colorScheme.error : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              helperText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.label,
    required this.onPressed,
    this.value,
  });

  final String label;
  final int? value;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      onPressed: onPressed,
      avatar: const Icon(Icons.payments_outlined, size: 18),
      label: Text(value == null ? label : '$label ${_formatCurrency(value!)}'),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _KeypadPreview extends StatelessWidget {
  const _KeypadPreview({required this.onKeyPressed, required this.onDelete});

  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '00', '0'];

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.65,
      children: [
        for (final label in labels)
          _KeypadButton(label: label, onTap: () => onKeyPressed(label)),
        _KeypadButton(
          icon: Icons.backspace_rounded,
          isDestructive: true,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.onTap,
    this.label,
    this.icon,
    this.isDestructive = false,
  });

  final VoidCallback onTap;
  final String? label;
  final IconData? icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = isDestructive
        ? colorScheme.errorContainer.withValues(alpha: 0.55)
        : colorScheme.surfaceContainerLow;
    final borderColor = isDestructive
        ? colorScheme.error.withValues(alpha: 0.35)
        : colorScheme.outlineVariant;
    final iconColor = isDestructive
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: icon == null
              ? Text(
                  label ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

class _CashOrderDetailPanel extends StatelessWidget {
  const _CashOrderDetailPanel({
    required this.order,
    required this.shrinkWrapItems,
  });

  final OrderEntity order;
  final bool shrinkWrapItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemList = ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: order.items.length,
      shrinkWrap: shrinkWrapItems,
      physics: shrinkWrapItems ? const NeverScrollableScrollPhysics() : null,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _CashOrderLineTile(line: order.items[index]);
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
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 22,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Order',
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
          if (shrinkWrapItems) itemList else Expanded(child: itemList),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    _formatCurrency(order.totalAmount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
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

class _CashOrderLineTile extends StatelessWidget {
  const _CashOrderLineTile({required this.line});

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
            SizedBox.square(
              dimension: 38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
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

class _MissingCashPaymentState extends StatelessWidget {
  const _MissingCashPaymentState({required this.onBack});

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
              Icons.point_of_sale_outlined,
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

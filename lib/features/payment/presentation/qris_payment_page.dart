import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/widgets.dart';
import '../../orders/domain/entities/order_entity.dart';
import '../../orders/domain/entities/order_line_entity.dart';
import 'cubit/qris_payment_cubit.dart';

class QrisPaymentPage extends StatelessWidget {
  const QrisPaymentPage({super.key, required this.order});

  final OrderEntity? order;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QrisPaymentCubit>(param1: order),
      child: const _QrisPaymentView(),
    );
  }
}

class _QrisPaymentView extends StatelessWidget {
  const _QrisPaymentView();

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrisPaymentCubit, QrisPaymentState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == QrisPaymentStatus.completed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.noticeMessage ?? 'Pembayaran selesai.'),
            ),
          );
          context.go('/orders');
          return;
        }

        if (state.status == QrisPaymentStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Pembayaran QRIS gagal diselesaikan.',
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
                        _QrisPaymentHeader(
                          order: order,
                          onBack: () => _goBack(context),
                        ),
                        const SizedBox(height: 14),
                        if (order == null)
                          Expanded(
                            child: _MissingQrisPaymentState(
                              onBack: () => _goBack(context),
                            ),
                          )
                        else
                          Expanded(
                            child: _QrisPaymentBody(
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

class _QrisPaymentHeader extends StatelessWidget {
  const _QrisPaymentHeader({required this.order, required this.onBack});

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
                'QRIS Payment',
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

class _QrisPaymentBody extends StatelessWidget {
  const _QrisPaymentBody({required this.order, required this.isCompact});

  final OrderEntity order;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final paymentPanel = _QrisTenderPanel(order: order);
    final detailPanel = _QrisOrderDetailPanel(
      order: order,
      shrinkWrapItems: isCompact,
    );

    if (isCompact) {
      return ListView(
        children: [paymentPanel, const SizedBox(height: 14), detailPanel],
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

class _QrisTenderPanel extends StatelessWidget {
  const _QrisTenderPanel({required this.order});

  final OrderEntity order;

  Future<void> _showFinishConfirmation(BuildContext context) async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran QRIS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogAmountRow(
                label: 'Total Tagihan',
                value: order.totalAmount,
              ),
              const SizedBox(height: 8),
              const _DialogTextRow(label: 'Metode', value: 'QRIS'),
              const SizedBox(height: 8),
              _DialogTextRow(label: 'Referensi', value: order.orderNumber),
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
      await context.read<QrisPaymentCubit>().completePayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<QrisPaymentCubit, QrisPaymentState>(
      builder: (context, state) {
        final cubit = context.read<QrisPaymentCubit>();
        final isPaymentDetected = state.isPaymentDetected;

        return AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
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
                          Icons.qr_code_2_outlined,
                          size: 22,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pembayaran QRIS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QrisNotificationIndicator(
                      state: state,
                      onOpenSettings: cubit.openNotificationPermissionSettings,
                      onRetry: cubit.startNotificationListener,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TotalDueCard(total: order.totalAmount),
                const SizedBox(height: 12),
                _QrisCodeCard(
                  order: order,
                  isPaymentDetected: isPaymentDetected,
                  detectedNotificationTitle: state.detectedNotificationTitle,
                  detectedNotificationText: state.detectedNotificationText,
                ),
                const SizedBox(height: 12),
                _PaymentReferenceRow(
                  label: 'Nomor Order',
                  value: order.orderNumber,
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 8),
                const _PaymentReferenceRow(
                  label: 'Metode',
                  value: 'QRIS',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.isCompletingPayment
                      ? null
                      : isPaymentDetected
                      ? cubit.completePayment
                      : () => _showFinishConfirmation(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: state.isCompletingPayment
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isPaymentDetected
                              ? Icons.done_all_outlined
                              : Icons.check_circle_outline,
                        ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      state.isCompletingPayment
                          ? 'Memproses...'
                          : isPaymentDetected
                          ? 'Selesai'
                          : 'Konfirmasi Sudah Dibayar',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QrisCodeCard extends StatelessWidget {
  const _QrisCodeCard({
    required this.order,
    required this.isPaymentDetected,
    required this.detectedNotificationTitle,
    required this.detectedNotificationText,
  });

  final OrderEntity order;
  final bool isPaymentDetected;
  final String? detectedNotificationTitle;
  final String? detectedNotificationText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final seed = '${order.id}:${order.orderNumber}:${order.totalAmount}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth < 230
                    ? constraints.maxWidth
                    : 230.0;

                return SizedBox.square(
                  dimension: size,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isPaymentDetected
                        ? const _QrisPaidMark(key: ValueKey('paid-qris'))
                        : _QrisCodeMark(
                            key: const ValueKey('pending-qris'),
                            seed: seed,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              isPaymentDetected ? 'Pembayaran Berhasil' : 'QRIS',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isPaymentDetected
                  ? detectedNotificationTitle ?? 'Terdeteksi dari notifikasi'
                  : 'Referensi ${order.orderNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (isPaymentDetected && detectedNotificationText != null) ...[
              const SizedBox(height: 3),
              Text(
                detectedNotificationText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QrisCodeMark extends StatelessWidget {
  const _QrisCodeMark({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffececec)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomPaint(
          painter: _QrisCodePainter(seed: seed),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _QrisPaidMark extends StatelessWidget {
  const _QrisPaidMark({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(
        Icons.check_circle_rounded,
        size: 112,
        color: colorScheme.primary,
      ),
    );
  }
}

class _QrisCodePainter extends CustomPainter {
  const _QrisCodePainter({required this.seed});

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 29;
    final cell = size.shortestSide / modules;
    final darkPaint = Paint()..color = const Color(0xff121212);
    final lightPaint = Paint()..color = Colors.white;
    final accentPaint = Paint()..color = const Color(0xffc9181f);

    canvas.drawRect(Offset.zero & size, lightPaint);

    void drawModule(int x, int y, Paint paint) {
      final rect = Rect.fromLTWH(x * cell, y * cell, cell, cell);
      canvas.drawRect(rect, paint);
    }

    void drawFinder(int startX, int startY) {
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 7; x++) {
          final isOuter = x == 0 || x == 6 || y == 0 || y == 6;
          final isInner = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (isOuter || isInner) {
            drawModule(startX + x, startY + y, darkPaint);
          }
        }
      }
    }

    bool isFinderArea(int x, int y) {
      final inLeft = x >= 0 && x < 8;
      final inTop = y >= 0 && y < 8;
      final inRight = x >= modules - 8 && x < modules;
      final inBottom = y >= modules - 8 && y < modules;

      return inLeft && inTop || inRight && inTop || inLeft && inBottom;
    }

    drawFinder(0, 0);
    drawFinder(modules - 7, 0);
    drawFinder(0, modules - 7);

    var value = 0x45d9f3b;
    for (final codeUnit in seed.codeUnits) {
      value = ((value * 31) ^ codeUnit) & 0x7fffffff;
    }

    for (var y = 0; y < modules; y++) {
      for (var x = 0; x < modules; x++) {
        if (isFinderArea(x, y)) continue;

        value = (value * 1103515245 + 12345) & 0x7fffffff;
        final isTiming = x == 6 || y == 6;
        final shouldDraw = isTiming ? (x + y).isEven : value % 7 < 3;

        if (shouldDraw) {
          drawModule(x, y, (x - y).abs() % 13 == 0 ? accentPaint : darkPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrisCodePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

class _PaymentReferenceRow extends StatelessWidget {
  const _PaymentReferenceRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrisNotificationIndicator extends StatelessWidget {
  const _QrisNotificationIndicator({
    required this.state,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final QrisPaymentState state;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final indicator = _indicatorData(context);
    final dot = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: indicator.color,
        shape: BoxShape.circle,
        border: Border.all(color: indicator.borderColor, width: 2),
      ),
    );

    return Tooltip(
      message: indicator.tooltip,
      child: Semantics(
        label: indicator.tooltip,
        button: indicator.onPressed != null,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: indicator.onPressed,
            customBorder: const CircleBorder(),
            child: Padding(padding: const EdgeInsets.all(8), child: dot),
          ),
        ),
      ),
    );
  }

  _QrisIndicatorData _indicatorData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const readyColor = Color(0xff2e7d32);
    const startingColor = Color(0xfff9a825);
    final inactiveColor = colorScheme.outline;

    if (state.isPaymentDetected) {
      return _QrisIndicatorData(
        color: readyColor,
        borderColor: readyColor.withValues(alpha: 0.25),
        tooltip: 'Pembayaran QRIS terdeteksi',
      );
    }

    return switch (state.listenerStatus) {
      QrisNotificationListenerStatus.starting => _QrisIndicatorData(
        color: startingColor,
        borderColor: startingColor.withValues(alpha: 0.25),
        tooltip: 'Mengaktifkan listener notifikasi',
      ),
      QrisNotificationListenerStatus.ready => _QrisIndicatorData(
        color: readyColor,
        borderColor: readyColor.withValues(alpha: 0.25),
        tooltip: 'Menunggu notifikasi myBCA',
      ),
      QrisNotificationListenerStatus.permissionRequired => _QrisIndicatorData(
        color: colorScheme.error,
        borderColor: colorScheme.error.withValues(alpha: 0.25),
        tooltip: 'Izin notifikasi belum aktif',
        onPressed: onOpenSettings,
      ),
      QrisNotificationListenerStatus.failure => _QrisIndicatorData(
        color: colorScheme.error,
        borderColor: colorScheme.error.withValues(alpha: 0.25),
        tooltip: 'Listener notifikasi tidak aktif',
        onPressed: onRetry,
      ),
      QrisNotificationListenerStatus.initial => _QrisIndicatorData(
        color: inactiveColor,
        borderColor: inactiveColor.withValues(alpha: 0.25),
        tooltip: 'Menyiapkan listener notifikasi',
      ),
    };
  }
}

class _QrisIndicatorData {
  const _QrisIndicatorData({
    required this.color,
    required this.borderColor,
    required this.tooltip,
    this.onPressed,
  });

  final Color color;
  final Color borderColor;
  final String tooltip;
  final VoidCallback? onPressed;
}

class _DialogAmountRow extends StatelessWidget {
  const _DialogAmountRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return _DialogTextRow(label: label, value: _formatCurrency(value));
  }
}

class _DialogTextRow extends StatelessWidget {
  const _DialogTextRow({required this.label, required this.value});

  final String label;
  final String value;

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
          value,
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

class _QrisOrderDetailPanel extends StatelessWidget {
  const _QrisOrderDetailPanel({
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
        return _QrisOrderLineTile(line: order.items[index]);
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

class _QrisOrderLineTile extends StatelessWidget {
  const _QrisOrderLineTile({required this.line});

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

class _MissingQrisPaymentState extends StatelessWidget {
  const _MissingQrisPaymentState({required this.onBack});

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
              Icons.qr_code_2_outlined,
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

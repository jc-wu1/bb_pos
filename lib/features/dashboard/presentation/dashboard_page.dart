import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/dependencies/injector.dart';
import '../../../shared/widgets/widgets.dart';
import '../../orders/domain/entities/order_payment_method.dart';
import '../../orders/domain/entities/order_status.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'cubit/dashboard_cubit.dart';

const Color _dashboardHeaderBackground = Color(0xfffff1e8);
const Color _dashboardHeaderBorder = Color(0xffffc46b);
const Color _dashboardHeaderForeground = Color(0xff6b1b00);
const Color _dashboardHeaderMuted = Color(0xff9a4d00);

const Color _salesCardBackground = Color(0xffffedbf);
const Color _salesCardForeground = Color(0xff725c00);
const Color _popularCardBackground = Color(0xffffdad6);
const Color _popularCardForeground = Color(0xff93000a);
const Color _orderCardBackground = Color(0xfffff3b0);
const Color _orderCardForeground = Color(0xff574500);
const Color _averageCardBackground = Color(0xffffdcc2);
const Color _averageCardForeground = Color(0xff6f3600);

const Color _honeyAccent = Color(0xffd97706);
const Color _racingRedAccent = Color(0xffc9181f);
const Color _goldAccent = Color(0xff9a4d00);
const Color _tomatoAccent = Color(0xffdc4a2d);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) {
        return previous.errorSerial != current.errorSerial &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 720;
              final horizontalPadding = isCompact ? 14.0 : 22.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: _DashboardBody(state: state),
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

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final snapshot = state.snapshot;

    if (state.isInitialLoading) {
      return const _DashboardLoadingState();
    }

    if (snapshot == null) {
      return _DashboardFailureState(
        onRetry: context.read<DashboardCubit>().retry,
      );
    }

    return _DashboardContent(snapshot: snapshot);
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1040;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DashboardHeader(todayLabel: _formatToday(snapshot.generatedAt)),
            const SizedBox(height: 14),
            if (!snapshot.hasMenuItems)
              _NoMenuEmptyState(onOpenMenu: () => context.go('/menu'))
            else ...[
              _MetricGrid(metrics: _metricsFor(snapshot)),
              if (!snapshot.hasTodayData) ...[
                const SizedBox(height: 14),
                _NoSalesCallout(onOpenOrders: () => context.go('/orders')),
              ],
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TopMenuCard(items: snapshot.topMenuItems),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: _PaymentMethodTotalsCard(
                        items: snapshot.paymentMethodTotals,
                      ),
                    ),
                  ],
                )
              else ...[
                _TopMenuCard(items: snapshot.topMenuItems),
                const SizedBox(height: 14),
                _PaymentMethodTotalsCard(items: snapshot.paymentMethodTotals),
              ],
              const SizedBox(height: 14),
              _RecentOrdersCard(orders: snapshot.recentOrders),
            ],
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.todayLabel});

  final String todayLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showImage = constraints.maxWidth >= 680;

        return Container(
          decoration: BoxDecoration(
            color: _dashboardHeaderBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _dashboardHeaderBorder),
          ),
          padding: EdgeInsets.all(showImage ? 22 : 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todayLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _dashboardHeaderMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ringkasan Hari Ini',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: _dashboardHeaderForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cek penjualan, order, menu favorit, dan pembayaran hari ini dari satu tempat.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _dashboardHeaderMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (showImage) ...[
                const SizedBox(width: 18),
                Image.asset(
                  'assets/images/Home Cooked Meal.png',
                  height: 132,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1020
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final maxCrossAxisExtent = constraints.maxWidth > 0
            ? constraints.maxWidth / columns
            : 1.0;

        return GridView.builder(
          itemCount: metrics.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 132,
          ),
          itemBuilder: (context, index) {
            return _MetricCard(metric: metrics[index]);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      color: metric.backgroundColor,
      borderColor: metric.foregroundColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: metric.foregroundColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(metric.icon, color: metric.foregroundColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: metric.foregroundColor.withValues(alpha: 0.76),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: metric.foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: metric.foregroundColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMenuEmptyState extends StatelessWidget {
  const _NoMenuEmptyState({required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Food Menu Streamline Milano.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            Text(
              'Menu belum diisi',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan beberapa menu dulu supaya penjualan bisa mulai terbaca di dashboard.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onOpenMenu,
              icon: const Icon(Icons.restaurant_menu_outlined),
              label: const Text('Tambah menu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSalesCallout extends StatelessWidget {
  const _NoSalesCallout({required this.onOpenOrders});

  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      color: colorScheme.primaryContainer.withValues(alpha: 0.42),
      borderColor: colorScheme.primary.withValues(alpha: 0.24),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: colorScheme.onPrimaryContainer,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada order selesai hari ini',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mulai dari order pertama, nanti ringkasannya otomatis muncul di sini.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.76,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onOpenOrders,
            icon: const Icon(Icons.add),
            label: const Text('Buat order'),
          ),
        ],
      ),
    );
  }
}

class _TopMenuCard extends StatelessWidget {
  const _TopMenuCard({required this.items});

  final List<DashboardTopMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Menu Favorit Hari Ini',
            subtitle: 'Diurutkan dari omzet order yang sudah dibayar',
            icon: Icons.restaurant_menu_outlined,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const _PanelEmptyMessage(
              icon: Icons.local_dining_outlined,
              message:
                  'Belum ada menu terjual dari order yang sudah dibayar hari ini.',
            )
          else
            for (final entry in items.indexed) ...[
              _TopMenuRow(
                item: entry.$2,
                colorRole: _dashboardColorRoleForIndex(entry.$1),
              ),
              if (entry.$1 < items.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _TopMenuRow extends StatelessWidget {
  const _TopMenuRow({required this.item, required this.colorRole});

  final DashboardTopMenuItem item;
  final _DashboardColorRole colorRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressColor = _dashboardColor(colorRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} • ${item.orderedCount} porsi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatCurrency(item.revenue),
              style: theme.textTheme.labelLarge?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: item.revenueShare.clamp(0, 1),
            minHeight: 6,
            color: progressColor,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTotalsCard extends StatelessWidget {
  const _PaymentMethodTotalsCard({required this.items});

  final List<DashboardPaymentMethodTotal> items;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Pembayaran Hari Ini',
            subtitle: 'Total penjualan dari order dibayar per metode',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 14),
          for (final entry in items.indexed) ...[
            _PaymentMethodTotalRow(
              item: entry.$2,
              colorRole: _dashboardColorRoleForIndex(entry.$1),
            ),
            if (entry.$1 < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodTotalRow extends StatelessWidget {
  const _PaymentMethodTotalRow({required this.item, required this.colorRole});

  final DashboardPaymentMethodTotal item;
  final _DashboardColorRole colorRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressColor = _dashboardColor(colorRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  _paymentMethodIcon(item.method),
                  color: progressColor,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.method.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.transactionCount} transaksi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatCurrency(item.totalAmount),
              style: theme.textTheme.labelLarge?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: item.share.clamp(0, 1),
            minHeight: 6,
            color: progressColor,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

IconData _paymentMethodIcon(OrderPaymentMethod method) {
  return switch (method) {
    OrderPaymentMethod.cash => Icons.payments_outlined,
    OrderPaymentMethod.qris => Icons.qr_code_2_outlined,
  };
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard({required this.orders});

  final List<DashboardRecentOrder> orders;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Order Terakhir Dibayar',
            subtitle: 'Order terbaru yang pembayarannya sudah selesai',
            icon: Icons.receipt_outlined,
          ),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            const _PanelEmptyMessage(
              icon: Icons.receipt_long_outlined,
              message: 'Belum ada order yang sudah dibayar hari ini.',
            )
          else
            for (final entry in orders.indexed) ...[
              _RecentOrderTile(order: entry.$2),
              if (entry.$1 < orders.length - 1) const Divider(height: 14),
            ],
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final DashboardRecentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pillStatus = _statusForOrder(order.status);
    final statusColor = pillStatus.foregroundColor(colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.room_service_outlined,
                color: statusColor,
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
                  '${order.orderNumber} • ${order.customerLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.itemCount} item • Lunas ${_formatTime(order.paidAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(order.totalAmount),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              StatusPill(status: pillStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelEmptyMessage extends StatelessWidget {
  const _PanelEmptyMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

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
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              'Menyiapkan ringkasan...',
              style: theme.textTheme.titleMedium?.copyWith(
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

class _DashboardFailureState extends StatelessWidget {
  const _DashboardFailureState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 46, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Ringkasan belum bisa dimuat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: _salesCardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, color: _salesCardForeground, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
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

class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}

enum _DashboardColorRole { primary, secondary, tertiary, error }

List<_DashboardMetric> _metricsFor(DashboardSnapshot snapshot) {
  final topItem = snapshot.topMenuItems.isEmpty
      ? null
      : snapshot.topMenuItems.first;

  return [
    _DashboardMetric(
      title: 'Penjualan Hari Ini',
      value: _formatCurrency(snapshot.totalSalesToday),
      subtitle: _formatComparison(
        current: snapshot.totalSalesToday,
        previous: snapshot.totalSalesYesterday,
      ),
      icon: Icons.payments_outlined,
      backgroundColor: _salesCardBackground,
      foregroundColor: _salesCardForeground,
    ),
    _DashboardMetric(
      title: 'Menu Favorit Hari Ini',
      value: topItem?.name ?? 'Belum ada',
      subtitle: topItem == null
          ? 'Belum ada order yang sudah dibayar hari ini'
          : '${topItem.orderedCount} porsi • ${_formatCurrency(topItem.revenue)}',
      icon: Icons.local_fire_department_outlined,
      backgroundColor: _popularCardBackground,
      foregroundColor: _popularCardForeground,
    ),
    _DashboardMetric(
      title: 'Order Selesai Hari Ini',
      value: '${snapshot.completedOrdersToday}',
      subtitle: _formatComparison(
        current: snapshot.completedOrdersToday,
        previous: snapshot.completedOrdersYesterday,
      ),
      icon: Icons.receipt_long_outlined,
      backgroundColor: _orderCardBackground,
      foregroundColor: _orderCardForeground,
    ),
    _DashboardMetric(
      title: 'Rata-rata per Order',
      value: _formatCurrency(snapshot.averagePurchaseToday),
      subtitle: _formatComparison(
        current: snapshot.averagePurchaseToday,
        previous: snapshot.averagePurchaseYesterday,
      ),
      icon: Icons.shopping_bag_outlined,
      backgroundColor: _averageCardBackground,
      foregroundColor: _averageCardForeground,
    ),
  ];
}

_DashboardColorRole _dashboardColorRoleForIndex(int index) {
  return switch (index % 4) {
    0 => _DashboardColorRole.primary,
    1 => _DashboardColorRole.secondary,
    2 => _DashboardColorRole.tertiary,
    _ => _DashboardColorRole.error,
  };
}

Color _dashboardColor(_DashboardColorRole role) {
  return switch (role) {
    _DashboardColorRole.primary => _honeyAccent,
    _DashboardColorRole.secondary => _racingRedAccent,
    _DashboardColorRole.tertiary => _goldAccent,
    _DashboardColorRole.error => _tomatoAccent,
  };
}

StatusPillStatus _statusForOrder(OrderStatus status) {
  return switch (status) {
    OrderStatus.open => StatusPillStatus.open,
    OrderStatus.completed => StatusPillStatus.completed,
    OrderStatus.canceled => StatusPillStatus.canceled,
  };
}

String _formatCurrency(int value) {
  return 'Rp ${NumberFormat.decimalPattern('id_ID').format(value)}';
}

String _formatComparison({required int current, required int previous}) {
  if (previous == 0) return 'Belum ada pembanding kemarin';

  final change = ((current - previous) / previous * 100).round();
  if (change == 0) return 'Sama dengan kemarin';

  final direction = change > 0 ? 'Naik' : 'Turun';
  return '$direction ${change.abs()}% dari kemarin';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}.'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _formatToday(DateTime date) {
  const weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

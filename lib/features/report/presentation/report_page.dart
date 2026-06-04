import 'package:flutter/material.dart';

import '../../../shared/widgets/widgets.dart';

const Color _reportHeaderBackground = Color(0xfffff1e8);
const Color _reportHeaderBorder = Color(0xffffc46b);
const Color _reportHeaderForeground = Color(0xff6b1b00);
const Color _reportHeaderMuted = Color(0xff9a4d00);

const Color _salesAccent = Color(0xffd97706);
const Color _ordersAccent = Color(0xffc9181f);
const Color _menuAccent = Color(0xff0f9f6e);
const Color _cashAccent = Color(0xffdc4a2d);

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: const _ReportContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReportHeader(),
        SizedBox(height: 14),
        _ReportControls(),
        SizedBox(height: 14),
        _DataSourceCard(),
        SizedBox(height: 14),
        _DailyReportSection(),
        SizedBox(height: 14),
        _WeeklyReportSection(),
        SizedBox(height: 14),
        _MonthlyReportSection(),
      ],
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      color: _reportHeaderBackground,
      borderColor: _reportHeaderBorder,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: _reportHeaderForeground,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _reportHeaderForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preview UI laporan berdasarkan data order, transaksi, menu, dan kategori yang tersedia.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _reportHeaderMuted,
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

class _ReportControls extends StatelessWidget {
  const _ReportControls();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.calendar_today_outlined),
            label: const Text('Pilih Periode'),
          ),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filter Status'),
          ),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _DataSourceCard extends StatelessWidget {
  const _DataSourceCard();

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Data yang tersedia',
            subtitle:
                'UI ini hanya menampilkan laporan yang bisa dibentuk dari schema saat ini.',
            icon: Icons.storage_outlined,
            color: _ordersAccent,
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SourceChip(label: 'orders'),
              _SourceChip(label: 'order_items'),
              _SourceChip(label: 'transactions'),
              _SourceChip(label: 'menu_items'),
              _SourceChip(label: 'categories'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyReportSection extends StatelessWidget {
  const _DailyReportSection();

  @override
  Widget build(BuildContext context) {
    return const _ReportSection(
      title: 'Harian',
      subtitle: 'Laporan operasional per tanggal.',
      reports: [
        _ReportCardData(
          title: 'Laporan Penjualan Harian',
          description:
              'Total omzet, jumlah transaksi selesai, dan rata-rata transaksi.',
          icon: Icons.today_outlined,
          color: _salesAccent,
          sampleTitle: 'Hari ini',
          sampleValue: 'Rp 8.450.000',
          sampleMeta: '126 transaksi selesai | Avg Rp 67.000',
          sources: [
            'orders.total_amount',
            'orders.status',
            'orders.created_at',
          ],
        ),
        _ReportCardData(
          title: 'Laporan per Menu',
          description:
              'Menu paling laku berdasarkan item order dan kuantitas terjual.',
          icon: Icons.restaurant_menu_outlined,
          color: _menuAccent,
          sampleTitle: 'Top menu',
          sampleValue: 'Nasi Ayam Geprek',
          sampleMeta: '58 sold | Rp 1.740.000',
          sources: ['order_items', 'menu_items', 'categories'],
        ),
        _ReportCardData(
          title: 'Rekonsiliasi Kas Tercatat',
          description:
              'Ringkasan cash tercatat dari transaksi, belum termasuk hitung fisik laci.',
          icon: Icons.point_of_sale_outlined,
          color: _cashAccent,
          sampleTitle: 'Cash tercatat',
          sampleValue: 'Rp 3.620.000',
          sampleMeta: 'Cash, amount paid, change amount',
          sources: ['transactions.payment_method', 'transactions.amount_paid'],
        ),
      ],
    );
  }
}

class _WeeklyReportSection extends StatelessWidget {
  const _WeeklyReportSection();

  @override
  Widget build(BuildContext context) {
    return const _ReportSection(
      title: 'Mingguan',
      subtitle: 'Rekap tren yang masih berbasis data penjualan.',
      reports: [
        _ReportCardData(
          title: 'Rekap Penjualan Mingguan',
          description:
              'Tren omzet per hari, hari paling ramai, dan hari paling sepi.',
          icon: Icons.calendar_view_week_outlined,
          color: _ordersAccent,
          sampleTitle: 'Minggu ini',
          sampleValue: 'Rp 48.250.000',
          sampleMeta: 'Ramai: Sabtu | Sepi: Senin',
          sources: [
            'orders.created_at',
            'orders.total_amount',
            'transactions.paid_at',
          ],
        ),
      ],
    );
  }
}

class _MonthlyReportSection extends StatelessWidget {
  const _MonthlyReportSection();

  @override
  Widget build(BuildContext context) {
    return const _ReportSection(
      title: 'Bulanan',
      subtitle:
          'Analisis bulanan yang tidak membutuhkan data biaya, gaji, atau supplier.',
      reports: [
        _ReportCardData(
          title: 'Analisis Menu Terjual',
          description:
              'Menu paling laku dan kurang laku berdasarkan kuantitas penjualan bulanan.',
          icon: Icons.analytics_outlined,
          color: _menuAccent,
          sampleTitle: 'Menu unggulan',
          sampleValue: 'Es Kopi Susu',
          sampleMeta: '1.240 sold bulan ini',
          sources: [
            'order_items.quantity',
            'order_items.subtotal',
            'menu_items.name',
          ],
        ),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.reports,
  });

  final String title;
  final String subtitle;
  final List<_ReportCardData> reports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 960
                ? 3
                : constraints.maxWidth >= 640
                ? 2
                : 1;
            final itemWidth =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: reports
                  .map(
                    (report) => SizedBox(
                      width: itemWidth,
                      child: _ReportCard(report: report),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final _ReportCardData report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: report.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(report.icon, color: report.color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: report.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.sampleTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: report.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report.sampleValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.sampleMeta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: report.sources
                .map((source) => _SourceChip(label: source))
                .toList(),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Preview'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ReportCardData {
  const _ReportCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.sampleTitle,
    required this.sampleValue,
    required this.sampleMeta,
    required this.sources,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String sampleTitle;
  final String sampleValue;
  final String sampleMeta;
  final List<String> sources;
}

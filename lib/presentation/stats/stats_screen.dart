import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/thundra_card.dart';
import 'stats_controller.dart';
import 'stats_models.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(statsWindowProvider);
    final vmAsync = ref.watch(statsViewModelProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.midnightRaised,
        border: Border(bottom: BorderSide(color: AppColors.separator)),
        middle: Text('Stats'),
      ),
      child: SafeArea(
        top: false,
        child: vmAsync.when(
          loading: () => const Center(child: CupertinoActivityIndicator(radius: 12)),
          error: (error, stackTrace) => const Center(child: Text('Failed to load stats')),
          data: (vm) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _FilterRow(
                  value: window,
                  onChanged: (w) => ref.read(statsWindowProvider.notifier).state = w,
                ),
                const SizedBox(height: 12),
                _SummaryGrid(
                  vm: vm,
                  windowLabel: statsWindowLabel(window),
                ),
                const SizedBox(height: 12),
                if (vm.total == 0)
                  const ThundraCard(
                    child: Text(
                      'No strikes yet for this window. Keep THUNDRA running to build history.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                if (vm.total == 0) const SizedBox(height: 12),
                ThundraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily (last 14 days)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(height: 180, child: _DailyLineChart(vm.daily14)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ThundraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly (last 12 months)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(height: 200, child: _MonthlyBarChart(vm.monthly12)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.value, required this.onChanged});

  final StatsWindow value;
  final ValueChanged<StatsWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.midnightRaised,
      ),
      child: CupertinoSlidingSegmentedControl<StatsWindow>(
        groupValue: value,
        thumbColor: AppColors.accent.withValues(alpha: 0.24),
        backgroundColor: CupertinoColors.transparent,
        children: const {
          StatsWindow.today: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Today'),
          ),
          StatsWindow.days7: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('7 Days'),
          ),
          StatsWindow.days30: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('30 Days'),
          ),
          StatsWindow.allTime: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('All Time'),
          ),
        },
        onValueChanged: (v) {
          if (v == null) return;
          HapticFeedback.lightImpact();
          onChanged(v);
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.vm, required this.windowLabel});

  final StatsViewModel vm;
  final String windowLabel;

  @override
  Widget build(BuildContext context) {
    final dfDay = DateFormat('MMM d');
    final dfMonth = DateFormat('MMM yyyy');

    return Row(
      children: [
        Expanded(
          child: ThundraCard(
            child: _SummaryItem(
              title: 'Most active day',
              value: vm.mostActiveDay == null
                  ? '—'
                  : dfDay.format(vm.mostActiveDay!.label),
              subtitle: vm.mostActiveDay == null
                  ? 'No data'
                  : '${vm.mostActiveDay!.count} strikes',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThundraCard(
            child: _SummaryItem(
              title: 'Most active month',
              value: vm.mostActiveMonth == null
                  ? '—'
                  : dfMonth.format(vm.mostActiveMonth!.label),
              subtitle: vm.mostActiveMonth == null
                  ? 'No data'
                  : '${vm.mostActiveMonth!.count} strikes',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThundraCard(
            child: _SummaryItem(
              title: 'Total',
              value: '${vm.total}',
              subtitle: windowLabel,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart(this.daily);

  final List<DayCountPoint> daily;

  @override
  Widget build(BuildContext context) {
    final maxY = daily.isEmpty
        ? 1.0
        : daily.map((p) => p.count).reduce((a, b) => a > b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 3).clamp(1, 9999),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.stroke.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < daily.length; i++)
                FlSpot(i.toDouble(), daily[i].count.toDouble()),
            ],
            isCurved: true,
            color: AppColors.accent,
            barWidth: 2.2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart(this.monthly);

  final List<MonthCountPoint> monthly;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM');
    final maxY = monthly.isEmpty
        ? 1.0
        : monthly.map((p) => p.count).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 3).clamp(1, 9999),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.stroke.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= monthly.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    df.format(monthly[i].monthUtc),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < monthly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthly[i].count.toDouble(),
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accent.withValues(alpha: 0.75),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY == 0 ? 1 : maxY,
                    color: AppColors.stroke.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

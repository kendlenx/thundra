import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/thundra_card.dart';
import 'stats_controller.dart';
import 'stats_models.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final window = ref.watch(statsWindowProvider);
    final vmAsync = ref.watch(statsViewModelProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.midnightRaised,
        border: Border(bottom: BorderSide(color: AppColors.separator)),
        middle: const Text('Stats'),
        trailing: vmAsync.maybeWhen(
          data: (vm) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _shareSummary(vm),
            child: const Icon(
              CupertinoIcons.share,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      child: SafeArea(
        top: false,
        child: vmAsync.when(
          loading: () =>
              const Center(child: CupertinoActivityIndicator(radius: 12)),
          error: (error, stackTrace) =>
              const Center(child: Text('Failed to load stats')),
          data: (vm) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _FilterRow(
                  value: window,
                  onChanged: (w) =>
                      ref.read(statsWindowProvider.notifier).state = w,
                ),
                const SizedBox(height: 12),
                _SummaryGrid(vm: vm, windowLabel: statsWindowLabel(window)),
                const SizedBox(height: 12),
                _InviteCard(onShare: _shareInviteLink),
                const SizedBox(height: 12),
                RepaintBoundary(
                  key: _shareKey,
                  child: _ShareSummaryCard(vm: vm),
                ),
                const SizedBox(height: 12),
                if (vm.total == 0)
                  const ThundraCard(
                    child: Text(
                      'No strikes yet for this window. Keep THUNDRA running to build history.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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
                      SizedBox(
                        height: 200,
                        child: _MonthlyBarChart(vm.monthly12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ThundraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seasonality (by month)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _SeasonalityBarChart(vm.seasonality),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ThundraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Most active hour',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: _HourlyBarChart(vm.hourly24),
                      ),
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

  Future<void> _shareSummary(StatsViewModel vm) async {
    final growth = await ref.read(growthServiceProvider.future);
    await growth.trackEvent(
      'summary_shared',
      props: {'placement': 'stats_share_button'},
    );

    final boundary =
        _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 2.4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/thundra-summary.png');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'THUNDRA – last 24h summary');
  }

  Future<void> _shareInviteLink() async {
    HapticFeedback.lightImpact();
    final growth = await ref.read(growthServiceProvider.future);
    final inviteUri = await growth.buildReferralLink(source: 'stats_invite');
    await growth.trackEvent(
      'referral_shared',
      props: {
        'placement': 'stats_invite_card',
        'invite_url': inviteUri.toString(),
      },
    );

    await Share.share(
      'Track lightning with THUNDRA.\\n$inviteUri',
      subject: 'Join THUNDRA',
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

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.onShare});

  final Future<void> Function() onShare;

  @override
  Widget build(BuildContext context) {
    return ThundraCard(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite with deep-link',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Share your personal invite link. If the app is missing, it falls back to App Store.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: onShare,
            child: const Text(
              'Invite',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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
        : monthly
              .map((p) => p.count)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

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
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= monthly.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    df.format(monthly[i].monthUtc),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
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

class _SeasonalityBarChart extends StatelessWidget {
  const _SeasonalityBarChart(this.monthly);

  final List<MonthCountPoint> monthly;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM');
    final maxY = monthly.isEmpty
        ? 1.0
        : monthly
              .map((p) => p.count)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

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
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= monthly.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    df.format(monthly[i].monthUtc),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
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
                  color: AppColors.accent.withValues(alpha: 0.7),
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

class _HourlyBarChart extends StatelessWidget {
  const _HourlyBarChart(this.hourly);

  final List<HourCountPoint> hourly;

  @override
  Widget build(BuildContext context) {
    final maxY = hourly.isEmpty
        ? 1.0
        : hourly.map((p) => p.count).reduce((a, b) => a > b ? a : b).toDouble();

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
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= hourly.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${hourly[i].hour}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < hourly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: hourly[i].count.toDouble(),
                  width: 6,
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.accent.withValues(alpha: 0.7),
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

class _ShareSummaryCard extends StatelessWidget {
  const _ShareSummaryCard({required this.vm});

  final StatsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final dfDay = DateFormat('MMM d');
    final dfMonth = DateFormat('MMM yyyy');
    final top = vm.topRegion24h;

    return ThundraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 24h summary',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Total strikes: ${vm.total24h}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Most active day: ${vm.mostActiveDay == null ? '—' : dfDay.format(vm.mostActiveDay!.label)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Most active month: ${vm.mostActiveMonth == null ? '—' : dfMonth.format(vm.mostActiveMonth!.label)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            top == null
                ? 'Top region: —'
                : 'Top region: ${top.count} strikes near '
                      '${top.lat.toStringAsFixed(1)}, '
                      '${top.lon.toStringAsFixed(1)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

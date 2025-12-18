import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import 'alerts/alerts_banner.dart';
import 'alerts/alerts_engine.dart';
import 'providers/app_providers.dart';
import 'live/live_map_screen.dart';
import 'heatmap/heatmap_screen.dart';
import 'alerts/alerts_screen.dart';
import 'stats/stats_screen.dart';
import 'providers/watch_sync_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  DateTime? _lastBannerAt;

  @override
  Widget build(BuildContext context) {
    ref.watch(appStartupProvider);
    ref.watch(strikeRetentionProvider);
    ref.watch(watchSyncServiceProvider);
    ref.listen<AlertState>(alertStateProvider, (prev, next) {
      final ev = next.lastEvent;
      if (ev == null) return;
      if (_lastBannerAt != null && ev.occurredAt.isAtSameMomentAs(_lastBannerAt!)) {
        return;
      }
      _lastBannerAt = ev.occurredAt;

      AlertsBanner.show(
        context,
        message:
            'Lightning detected within ${ev.radiusKm} km. Stay aware.',
      );
    });

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.midnightRaised.withValues(alpha: 0.85),
        activeColor: AppColors.accent,
        inactiveColor: AppColors.textSecondary,
        border: const Border(top: BorderSide(color: AppColors.separator)),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bolt_horizontal_fill),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.circle_grid_3x3_fill),
            label: 'Heatmap',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell_fill),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_fill),
            label: 'Stats',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (_) {
            return switch (index) {
              0 => const LiveMapScreen(),
              1 => const HeatmapScreen(),
              2 => const AlertsScreen(),
              _ => const StatsScreen(),
            };
          },
        );
      },
    );
  }
}

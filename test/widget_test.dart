// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:thundra/domain/models/strike.dart';
import 'package:thundra/presentation/stats/stats_controller.dart' as stats;
import 'package:thundra/presentation/stats/stats_models.dart';
import 'package:thundra/main.dart';
import 'package:thundra/presentation/providers/app_providers.dart';
import 'package:thundra/presentation/live/live_map_controller.dart'
    as live_map;
import 'package:thundra/presentation/heatmap/heatmap_controller.dart' as heatmap;
import 'package:thundra/presentation/alerts/alerts_engine.dart';
import 'package:thundra/domain/models/heat_bin.dart';

class _TestAlertsEngine extends AlertsEngine {
  @override
  AlertState build() => AlertState.initial;
}

class _TestHeatBinsController extends heatmap.HeatBinsController {
  @override
  Future<List<HeatBin>> build() async => const <HeatBin>[];
}

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStartupProvider.overrideWith((ref) async {}),
          strikeRetentionProvider.overrideWith((ref) {}),
          // Avoid timers/network during widget tests.
          live_map.liveStrikesProvider
              .overrideWith((ref) => Stream.value(const <Strike>[])),
          heatmap.heatBinsProvider.overrideWith(_TestHeatBinsController.new),
          alertStateProvider.overrideWith(_TestAlertsEngine.new),
          stats.statsViewModelProvider.overrideWith(
            (ref) => Stream.value(
              const StatsViewModel(
                total: 0,
                daily14: [],
                monthly12: [],
                mostActiveDay: null,
                mostActiveMonth: null,
              ),
            ),
          ),
        ],
        child: const ThundraApp(),
      ),
    );
    await tester.pump();
    expect(find.text('THUNDRA'), findsWidgets);
  });
}

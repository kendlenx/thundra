import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/strike.dart';
import '../providers/app_providers.dart';
import 'stats_models.dart';
import 'stats_aggregator.dart';

enum StatsWindow { today, days7, days30, allTime }

final statsWindowProvider = StateProvider<StatsWindow>((ref) {
  return StatsWindow.days7;
});

abstract interface class StatsStrikeSource {
  Stream<List<Strike>> watchSince(DateTime sinceUtc);
}

class InMemoryStatsStrikeSource implements StatsStrikeSource {
  InMemoryStatsStrikeSource(this._ref);

  final Ref _ref;

  @override
  Stream<List<Strike>> watchSince(DateTime sinceUtc) =>
      _ref.watch(strikeRepositoryProvider).watchSince(sinceUtc: sinceUtc);
}

final statsStrikeSourceProvider = Provider<StatsStrikeSource>((ref) {
  // TODO: swap to Drift-based source later without changing UI.
  return InMemoryStatsStrikeSource(ref);
});

String statsWindowLabel(StatsWindow window) {
  return switch (window) {
    StatsWindow.today => 'Today',
    StatsWindow.days7 => '7 Days',
    StatsWindow.days30 => '30 Days',
    StatsWindow.allTime => 'All Time',
  };
}

final statsViewModelProvider = StreamProvider<StatsViewModel>((ref) {
  final window = ref.watch(statsWindowProvider);
  final source = ref.watch(statsStrikeSourceProvider);

  final nowUtc = DateTime.now().toUtc();
  final fromUtc = windowStartUtc(window: window, nowUtc: nowUtc);

  return source.watchSince(fromUtc).map((strikes) {
    return computeStatsViewModel(
      strikes: strikes,
      window: window,
      nowUtc: DateTime.now().toUtc(),
    );
  });
});

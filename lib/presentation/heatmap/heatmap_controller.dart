import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/heat_bin.dart';
import '../../domain/models/strike.dart';
import '../providers/app_providers.dart';
import 'heatmap_aggregator.dart';

enum HeatmapWindow { today, days7, days30, allTime }

final heatmapWindowProvider = StateProvider<HeatmapWindow>((ref) {
  return HeatmapWindow.days7;
});

final heatmapBinSizeProvider = Provider<double>((ref) => 0.25);

abstract interface class HeatmapStrikeSource {
  Stream<List<Strike>> watchSince(DateTime sinceUtc);
}

class InMemoryHeatmapStrikeSource implements HeatmapStrikeSource {
  InMemoryHeatmapStrikeSource(this._ref);

  final Ref _ref;

  @override
  Stream<List<Strike>> watchSince(DateTime sinceUtc) {
    return _ref.watch(strikeRepositoryProvider).watchSince(sinceUtc: sinceUtc);
  }
}

final heatmapStrikeSourceProvider = Provider<HeatmapStrikeSource>((ref) {
  return InMemoryHeatmapStrikeSource(ref);
});

Duration _windowToDuration(HeatmapWindow window) {
  return switch (window) {
    HeatmapWindow.today => const Duration(days: 1),
    HeatmapWindow.days7 => const Duration(days: 7),
    HeatmapWindow.days30 => const Duration(days: 30),
    HeatmapWindow.allTime => const Duration(days: 3650),
  };
}

String windowLabel(HeatmapWindow window) {
  return switch (window) {
    HeatmapWindow.today => 'Today',
    HeatmapWindow.days7 => '7 Days',
    HeatmapWindow.days30 => '30 Days',
    HeatmapWindow.allTime => 'All Time',
  };
}

final heatBinsProvider =
    AsyncNotifierProvider<HeatBinsController, List<HeatBin>>(
  HeatBinsController.new,
);

class HeatBinsController extends AsyncNotifier<List<HeatBin>> {
  final Map<String, List<HeatBin>> _cache = {};
  StreamSubscription<List<Strike>>? _sub;
  Timer? _debounce;
  List<Strike> _latest = const [];

  @override
  FutureOr<List<HeatBin>> build() async {
    final window = ref.watch(heatmapWindowProvider);
    final binSize = ref.watch(heatmapBinSizeProvider);
    final source = ref.watch(heatmapStrikeSourceProvider);
    final aggregator = HeatmapAggregator(binSizeDegrees: binSize);
    final sinceUtc = _sinceUtcFor(window: window);
    final cacheKey = '${window.name}|$binSize';

    _sub?.cancel();
    _debounce?.cancel();
    _latest = const [];

    _sub = source.watchSince(sinceUtc).listen((strikes) {
      _latest = strikes;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        _recompute(
          cacheKey: cacheKey,
          window: window,
          sinceUtc: sinceUtc,
          aggregator: aggregator,
        );
      });
    });
    ref.onDispose(() {
      _debounce?.cancel();
      _sub?.cancel();
    });

    final cached = _cache[cacheKey];
    if (cached != null) {
      // Fast path on tab/filter switches.
      return cached;
    }

    // First compute.
    final first = await source.watchSince(sinceUtc).first;
    final computed = _aggregate(
      window: window,
      sinceUtc: sinceUtc,
      aggregator: aggregator,
      strikes: first,
    );
    _cache[cacheKey] = computed;
    return computed;
  }

  DateTime _sinceUtcFor({required HeatmapWindow window}) {
    final nowUtc = DateTime.now().toUtc();
    if (window == HeatmapWindow.today) {
      return DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    }
    return nowUtc.subtract(_windowToDuration(window));
  }

  void _recompute({
    required String cacheKey,
    required HeatmapWindow window,
    required DateTime sinceUtc,
    required HeatmapAggregator aggregator,
  }) {
    final computed = _aggregate(
      window: window,
      sinceUtc: sinceUtc,
      aggregator: aggregator,
      strikes: _latest,
    );
    _cache[cacheKey] = computed;
    state = AsyncValue.data(computed);
  }

  List<HeatBin> _aggregate({
    required HeatmapWindow window,
    required DateTime sinceUtc,
    required HeatmapAggregator aggregator,
    required List<Strike> strikes,
  }) {
    final now = DateTime.now().toUtc();
    return aggregator.aggregate(
      strikes: strikes,
      nowUtc: now,
      window: now.difference(sinceUtc),
    );
  }
}

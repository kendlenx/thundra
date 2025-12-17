import 'package:flutter_test/flutter_test.dart';

import 'package:thundra/domain/models/strike.dart';
import 'package:thundra/presentation/heatmap/heatmap_aggregator.dart';

void main() {
  test('aggregates strikes into deterministic bins', () {
    final now = DateTime.utc(2025, 1, 1, 12);
    final strikes = [
      Strike(id: 'a', lat: 10.10, lon: 20.10, timestamp: now),
      Strike(id: 'b', lat: 10.11, lon: 20.12, timestamp: now),
      Strike(id: 'c', lat: 10.49, lon: 20.49, timestamp: now),
    ];

    final agg = HeatmapAggregator(binSizeDegrees: 0.25);
    final bins = agg.aggregate(
      strikes: strikes,
      nowUtc: now,
      window: const Duration(minutes: 60),
    );

    // Two first strikes fall into same 0.25° bin, third into next.
    expect(bins.length, 2);
    expect(bins.first.count, 2);
    expect(bins.last.count, 1);

    // Verify bin start coordinates are deterministic.
    final first = bins.first;
    expect(first.latBin, 10.0);
    expect(first.lonBin, 20.0);
  });

  test('filters strikes by window before aggregating', () {
    final now = DateTime.utc(2025, 1, 1, 12);
    final old = now.subtract(const Duration(hours: 2));
    final strikes = [
      Strike(id: 'old', lat: 0.1, lon: 0.1, timestamp: old),
      Strike(id: 'new', lat: 0.1, lon: 0.1, timestamp: now),
    ];

    final agg = HeatmapAggregator(binSizeDegrees: 0.25);
    final bins = agg.aggregate(
      strikes: strikes,
      nowUtc: now,
      window: const Duration(minutes: 30),
    );

    expect(bins.length, 1);
    expect(bins.first.count, 1);
  });
}


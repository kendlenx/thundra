import 'package:flutter_test/flutter_test.dart';

import 'package:thundra/domain/models/strike.dart';
import 'package:thundra/presentation/stats/stats_aggregator.dart';
import 'package:thundra/presentation/stats/stats_controller.dart';

void main() {
  test('computes totals and highlights', () {
    final now = DateTime.utc(2025, 1, 15, 12);
    final strikes = <Strike>[
      // 3 strikes on Jan 10
      Strike(id: 'a', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 1, 10, 1)),
      Strike(id: 'b', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 1, 10, 2)),
      Strike(id: 'c', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 1, 10, 3)),
      // 1 strike on Jan 11
      Strike(id: 'd', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 1, 11, 3)),
      // 2 strikes in Dec 2024
      Strike(id: 'e', lat: 0, lon: 0, timestamp: DateTime.utc(2024, 12, 20, 3)),
      Strike(id: 'f', lat: 0, lon: 0, timestamp: DateTime.utc(2024, 12, 21, 3)),
    ];

    final vm = computeStatsViewModel(
      strikes: strikes,
      window: StatsWindow.allTime,
      nowUtc: now,
    );

    expect(vm.total, strikes.length);
    expect(vm.mostActiveDay?.label, DateTime.utc(2025, 1, 10));
    expect(vm.mostActiveDay?.count, 3);
    expect(vm.mostActiveMonth?.label, DateTime.utc(2025, 1));
    expect(vm.mostActiveMonth?.count, 4);
    expect(vm.daily14.length, 14);
    expect(vm.monthly12.length, 12);
  });

  test('applies window filter (today)', () {
    final now = DateTime.utc(2025, 2, 1, 12);
    final strikes = <Strike>[
      Strike(id: 'old', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 1, 31, 23, 59)),
      Strike(id: 'new', lat: 0, lon: 0, timestamp: DateTime.utc(2025, 2, 1, 0, 1)),
    ];

    final vm = computeStatsViewModel(
      strikes: strikes,
      window: StatsWindow.today,
      nowUtc: now,
    );

    expect(vm.total, 1);
  });
}


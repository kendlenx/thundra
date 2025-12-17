import 'dart:math' as math;

import '../../domain/models/heat_bin.dart';
import '../../domain/models/strike.dart';

class HeatmapAggregator {
  const HeatmapAggregator({this.binSizeDegrees = 0.25});

  final double binSizeDegrees;

  List<HeatBin> aggregate({
    required List<Strike> strikes,
    required DateTime nowUtc,
    required Duration window,
    int maxBins = 1400,
  }) {
    final cutoff = nowUtc.subtract(window);
    final bins = <String, int>{};

    for (final s in strikes) {
      if (s.timestamp.isBefore(cutoff)) continue;
      final latBin = _binStart(s.lat);
      final lonBin = _binStart(s.lon);
      bins['$latBin,$lonBin'] = (bins['$latBin,$lonBin'] ?? 0) + 1;
    }

    final results = bins.entries
        .map((e) {
          final parts = e.key.split(',');
          final latBin = double.parse(parts[0]);
          final lonBin = double.parse(parts[1]);
          return HeatBin(
            latBin: latBin,
            lonBin: lonBin,
            lat: latBin + binSizeDegrees / 2,
            lon: lonBin + binSizeDegrees / 2,
            count: e.value,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => b.count.compareTo(a.count));

    if (results.length <= maxBins) return results;
    return results.sublist(0, maxBins);
  }

  double _binStart(double value) {
    final scaled = value / binSizeDegrees;
    final floored = scaled.floorToDouble();
    // Avoid -0.0 keys.
    final start = floored * binSizeDegrees;
    return start == 0 ? 0 : start;
  }

  static double normalizeCount(int count, int maxCount) {
    if (maxCount <= 0) return 0;
    return math.min(1.0, count / maxCount);
  }
}


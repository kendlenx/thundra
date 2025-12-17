import 'dart:math';

import '../models/heatmap_bin.dart';
import '../repositories/strike_repository.dart';

class GetHeatmapBins {
  const GetHeatmapBins(this._repository);

  final StrikeRepository _repository;

  /// MVP: aggregates in-memory.
  /// TODO: Move aggregation to Drift SQL for large datasets.
  Future<List<HeatmapBin>> call({
    required DateTime from,
    required DateTime to,
    double gridDegrees = 0.5,
    int maxBins = 1200,
  }) async {
    final strikes = await _repository.listBetween(from: from, to: to);
    final bins = <String, int>{};

    for (final s in strikes) {
      final latKey = ((s.lat / gridDegrees).floorToDouble() * gridDegrees);
      final lonKey = ((s.lon / gridDegrees).floorToDouble() * gridDegrees);
      bins['$latKey,$lonKey'] = (bins['$latKey,$lonKey'] ?? 0) + 1;
    }

    final results = bins.entries
        .map((e) {
          final parts = e.key.split(',');
          final lat0 = double.parse(parts[0]);
          final lon0 = double.parse(parts[1]);
          return HeatmapBin(
            lat: lat0 + gridDegrees / 2,
            lon: lon0 + gridDegrees / 2,
            count: e.value,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => b.count.compareTo(a.count));

    if (results.length <= maxBins) return results;
    return results.sublist(0, maxBins);
  }

  static double normalize(double value, double max) {
    if (max <= 0) return 0;
    return min(1.0, value / max);
  }
}


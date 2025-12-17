import '../models/strike.dart';
import '../models/stats_snapshot.dart';
import '../repositories/strike_repository.dart';

class GetStats {
  const GetStats(this._repository);

  final StrikeRepository _repository;

  /// Returns daily counts for the last [days] and monthly counts for the last
  /// [months].
  Future<StatsSnapshot> call({
    int days = 30,
    int months = 12,
  }) async {
    final now = DateTime.now().toUtc();
    final from = DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final to = now.add(const Duration(minutes: 1));

    final strikes = await _repository.listBetween(from: from, to: to);

    final daily = _dailySeries(strikes: strikes, from: from, days: days);
    final monthly = _monthlySeries(strikes: strikes, now: now, months: months);

    final mostActiveDay = _maxDaily(daily);
    final total = strikes.length;

    return StatsSnapshot(
      daily: daily,
      monthly: monthly,
      mostActiveDay: mostActiveDay,
      total: total,
    );
  }

  List<DailyCountPoint> _dailySeries({
    required List<Strike> strikes,
    required DateTime from,
    required int days,
  }) {
    final counts = <DateTime, int>{};
    for (final s in strikes) {
      final ts = s.timestamp;
      final key = DateTime.utc(ts.year, ts.month, ts.day);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return List.generate(days, (i) {
      final day = DateTime.utc(from.year, from.month, from.day).add(Duration(days: i));
      return DailyCountPoint(day: day, count: counts[day] ?? 0);
    });
  }

  List<MonthlyCountPoint> _monthlySeries({
    required List<Strike> strikes,
    required DateTime now,
    required int months,
  }) {
    final firstMonth = DateTime.utc(now.year, now.month);
    final startMonth = DateTime.utc(firstMonth.year, firstMonth.month - (months - 1));

    final counts = <DateTime, int>{};
    for (final s in strikes) {
      final ts = s.timestamp;
      final key = DateTime.utc(ts.year, ts.month);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return List.generate(months, (i) {
      final month = DateTime.utc(startMonth.year, startMonth.month + i);
      return MonthlyCountPoint(month: month, count: counts[month] ?? 0);
    });
  }

  DailyCountPoint? _maxDaily(List<DailyCountPoint> daily) {
    if (daily.isEmpty) return null;
    var best = daily.first;
    for (final p in daily.skip(1)) {
      if (p.count > best.count) best = p;
    }
    return best;
  }
}

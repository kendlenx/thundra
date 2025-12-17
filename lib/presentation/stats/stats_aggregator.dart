import '../../domain/models/strike.dart';
import 'stats_controller.dart';
import 'stats_models.dart';

StatsViewModel computeStatsViewModel({
  required List<Strike> strikes,
  required StatsWindow window,
  required DateTime nowUtc,
}) {
  final fromUtc = windowStartUtc(window: window, nowUtc: nowUtc);
  final filtered = strikes
      .where((s) => !s.timestamp.toUtc().isBefore(fromUtc))
      .toList(growable: false);

  final total = filtered.length;
  final daily14 = dailySeries(filtered, nowUtc: nowUtc, days: 14);
  final monthly12 = monthlySeries(filtered, nowUtc: nowUtc, months: 12);
  final mostActiveDay = maxDayAcrossWindow(filtered);
  final mostActiveMonth = maxMonthAcrossWindow(filtered);

  return StatsViewModel(
    total: total,
    daily14: daily14,
    monthly12: monthly12,
    mostActiveDay: mostActiveDay,
    mostActiveMonth: mostActiveMonth,
  );
}

DateTime windowStartUtc({required StatsWindow window, required DateTime nowUtc}) {
  return switch (window) {
    StatsWindow.today => DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day),
    StatsWindow.days7 => nowUtc.subtract(const Duration(days: 7)),
    StatsWindow.days30 => nowUtc.subtract(const Duration(days: 30)),
    StatsWindow.allTime => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  };
}

List<DayCountPoint> dailySeries(
  List<Strike> strikes, {
  required DateTime nowUtc,
  required int days,
}) {
  final startDay = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day)
      .subtract(Duration(days: days - 1));

  final counts = <DateTime, int>{};
  for (final s in strikes) {
    final ts = s.timestamp.toUtc();
    final day = DateTime.utc(ts.year, ts.month, ts.day);
    counts[day] = (counts[day] ?? 0) + 1;
  }

  return List.generate(days, (i) {
    final day = DateTime.utc(startDay.year, startDay.month, startDay.day)
        .add(Duration(days: i));
    return DayCountPoint(dayUtc: day, count: counts[day] ?? 0);
  });
}

List<MonthCountPoint> monthlySeries(
  List<Strike> strikes, {
  required DateTime nowUtc,
  required int months,
}) {
  final first = DateTime.utc(nowUtc.year, nowUtc.month);
  final start = DateTime.utc(first.year, first.month - (months - 1));

  final counts = <DateTime, int>{};
  for (final s in strikes) {
    final ts = s.timestamp.toUtc();
    final month = DateTime.utc(ts.year, ts.month);
    counts[month] = (counts[month] ?? 0) + 1;
  }

  return List.generate(months, (i) {
    final month = DateTime.utc(start.year, start.month + i);
    return MonthCountPoint(monthUtc: month, count: counts[month] ?? 0);
  });
}

StatHighlight? maxDayAcrossWindow(List<Strike> strikes) {
  if (strikes.isEmpty) return null;
  final counts = <DateTime, int>{};
  for (final s in strikes) {
    final ts = s.timestamp.toUtc();
    final day = DateTime.utc(ts.year, ts.month, ts.day);
    counts[day] = (counts[day] ?? 0) + 1;
  }
  var bestDay = counts.keys.first;
  var bestCount = counts[bestDay]!;
  for (final e in counts.entries) {
    if (e.value > bestCount) {
      bestDay = e.key;
      bestCount = e.value;
    }
  }
  return StatHighlight(label: bestDay, count: bestCount);
}

StatHighlight? maxMonthAcrossWindow(List<Strike> strikes) {
  if (strikes.isEmpty) return null;
  final counts = <DateTime, int>{};
  for (final s in strikes) {
    final ts = s.timestamp.toUtc();
    final month = DateTime.utc(ts.year, ts.month);
    counts[month] = (counts[month] ?? 0) + 1;
  }
  var bestMonth = counts.keys.first;
  var bestCount = counts[bestMonth]!;
  for (final e in counts.entries) {
    if (e.value > bestCount) {
      bestMonth = e.key;
      bestCount = e.value;
    }
  }
  return StatHighlight(label: bestMonth, count: bestCount);
}


class DayCountPoint {
  const DayCountPoint({
    required this.dayUtc,
    required this.count,
  });

  /// UTC midnight.
  final DateTime dayUtc;
  final int count;
}

class MonthCountPoint {
  const MonthCountPoint({
    required this.monthUtc,
    required this.count,
  });

  /// UTC first of month.
  final DateTime monthUtc;
  final int count;
}

class StatHighlight {
  const StatHighlight({
    required this.label,
    required this.count,
  });

  final DateTime label;
  final int count;
}

class StatsViewModel {
  const StatsViewModel({
    required this.total,
    required this.daily14,
    required this.monthly12,
    required this.mostActiveDay,
    required this.mostActiveMonth,
  });

  final int total;
  final List<DayCountPoint> daily14;
  final List<MonthCountPoint> monthly12;
  final StatHighlight? mostActiveDay;
  final StatHighlight? mostActiveMonth;
}


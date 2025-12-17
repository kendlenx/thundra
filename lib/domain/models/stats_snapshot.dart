class DailyCountPoint {
  const DailyCountPoint({required this.day, required this.count});

  final DateTime day; // UTC midnight
  final int count;
}

class MonthlyCountPoint {
  const MonthlyCountPoint({required this.month, required this.count});

  final DateTime month; // UTC first of month
  final int count;
}

class StatsSnapshot {
  const StatsSnapshot({
    required this.daily,
    required this.monthly,
    required this.mostActiveDay,
    required this.total,
  });

  final List<DailyCountPoint> daily;
  final List<MonthlyCountPoint> monthly;
  final DailyCountPoint? mostActiveDay;
  final int total;
}


import 'package:drift/drift.dart';

class AlertEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get triggeredAtMillis => integer()();
  RealColumn get distanceKm => real()();
  IntColumn get radiusKm => integer()();
}


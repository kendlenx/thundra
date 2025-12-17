import 'package:drift/drift.dart';

class Strikes extends Table {
  TextColumn get id => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  IntColumn get timestampMillis => integer()();
  RealColumn get intensity => real().nullable()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK(lat >= -90 AND lat <= 90)',
        'CHECK(lon >= -180 AND lon <= 180)',
      ];
}


import 'package:drift/drift.dart';

class AlertSettingsTable extends Table {
  IntColumn get id => integer()();

  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get radiusKm => integer().withDefault(const Constant(10))();
  IntColumn get windowMinutes => integer().withDefault(const Constant(10))();

  BoolColumn get quietHoursEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get quietStartMinutes => integer().withDefault(const Constant(22 * 60))();
  IntColumn get quietEndMinutes => integer().withDefault(const Constant(7 * 60))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}


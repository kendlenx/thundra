import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/alert_events.dart';
import '../tables/alert_settings.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AlertSettingsTable, AlertEvents])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const int settingsRowId = 1;

  Future<AlertSettingsTableData?> getSettingsRow() {
    return (select(alertSettingsTable)
          ..where((t) => t.id.equals(settingsRowId)))
        .getSingleOrNull();
  }

  Stream<AlertSettingsTableData?> watchSettingsRow() {
    return (select(alertSettingsTable)
          ..where((t) => t.id.equals(settingsRowId)))
        .watchSingleOrNull();
  }

  Future<void> upsertSettings(AlertSettingsTableCompanion settings) async {
    await into(alertSettingsTable).insertOnConflictUpdate(settings);
  }

  Future<void> insertAlertEvent({
    required DateTime triggeredAt,
    required double distanceKm,
    required int radiusKm,
  }) async {
    await into(alertEvents).insert(
      AlertEventsCompanion.insert(
        triggeredAtMillis: triggeredAt.millisecondsSinceEpoch,
        distanceKm: distanceKm,
        radiusKm: radiusKm,
      ),
    );
  }
}


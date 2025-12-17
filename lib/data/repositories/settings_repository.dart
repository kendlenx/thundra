import 'package:drift/drift.dart' show Value;

import '../../domain/models/alert_settings.dart';
import '../db/app_database.dart' as db;

class SettingsRepository {
  SettingsRepository(this._database);

  final db.AppDatabase _database;

  Stream<AlertSettings> watchAlertSettings() {
    return _database.settingsDao.watchSettingsRow().map((row) {
      return _rowToDomain(row) ?? AlertSettings.defaults;
    });
  }

  Future<AlertSettings> getAlertSettings() async {
    final row = await _database.settingsDao.getSettingsRow();
    return _rowToDomain(row) ?? AlertSettings.defaults;
  }

  Future<void> saveAlertSettings(AlertSettings settings) async {
    await _database.settingsDao.upsertSettings(
      db.AlertSettingsTableCompanion.insert(
        id: const Value(1),
        enabled: Value(settings.enabled),
        radiusKm: Value(settings.radiusKm),
        windowMinutes: Value(settings.windowMinutes),
        quietHoursEnabled: Value(settings.quietHoursEnabled),
        quietStartMinutes: Value(settings.quietStartMinutes),
        quietEndMinutes: Value(settings.quietEndMinutes),
      ),
    );
  }

  Future<void> insertAlertEvent({
    required DateTime triggeredAtLocal,
    required double distanceKm,
    required int radiusKm,
  }) async {
    await _database.settingsDao.insertAlertEvent(
      triggeredAt: triggeredAtLocal,
      distanceKm: distanceKm,
      radiusKm: radiusKm,
    );
  }

  AlertSettings? _rowToDomain(db.AlertSettingsTableData? row) {
    if (row == null) return null;
    return AlertSettings(
      enabled: row.enabled,
      radiusKm: row.radiusKm,
      windowMinutes: row.windowMinutes,
      quietHoursEnabled: row.quietHoursEnabled,
      quietStartMinutes: row.quietStartMinutes,
      quietEndMinutes: row.quietEndMinutes,
    );
  }
}

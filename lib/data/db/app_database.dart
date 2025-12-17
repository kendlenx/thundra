import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'daos/settings_dao.dart';
import 'daos/strikes_dao.dart';
import 'tables/alert_events.dart';
import 'tables/alert_settings.dart';
import 'tables/strikes.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Strikes, AlertSettingsTable, AlertEvents],
  daos: [StrikesDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(alertSettingsTable);
            await migrator.createTable(alertEvents);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'thundra.sqlite',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
    native: DriftNativeOptions(
      databaseDirectory: () async {
        final dir = await getApplicationDocumentsDirectory();
        final dbDir = Directory('${dir.path}/db');
        if (!await dbDir.exists()) {
          await dbDir.create(recursive: true);
        }
        return dbDir;
      },
    ),
  );
}

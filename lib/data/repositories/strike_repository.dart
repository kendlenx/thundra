import 'package:drift/drift.dart' show Value;

import '../../domain/models/strike.dart';
import '../../domain/repositories/strike_repository.dart';
import '../db/app_database.dart' as db;

class DriftStrikeRepository implements StrikeRepository {
  DriftStrikeRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<Strike>> watchRecent({required Duration window}) {
    // Drift queries can't reference "now" dynamically, so we poll.
    // The DB remains the source of truth; this stream stays accurate over time.
    return _pollRecent(window: window, refresh: const Duration(seconds: 2));
  }

  @override
  Stream<List<Strike>> watchSince({required DateTime sinceUtc}) {
    return _database.strikesDao
        .watchRecent(since: sinceUtc)
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  @override
  Future<List<Strike>> listBetween({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _database.strikesDao.listBetween(from: from, to: to);
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> upsertStrike(Strike strike) async {
    await _database.strikesDao.upsertStrike(_toCompanion(strike));
  }

  @override
  Future<void> upsertStrikes(List<Strike> strikes) async {
    await _database.strikesDao.upsertStrikes(
      strikes.map(_toCompanion).toList(growable: false),
    );
  }

  @override
  Future<int> purgeOlderThan(DateTime cutoffUtc) {
    return _database.strikesDao.deleteOlderThan(cutoffUtc);
  }

  Strike _toDomain(db.Strike row) {
    return Strike(
      id: row.id,
      lat: row.lat,
      lon: row.lon,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestampMillis, isUtc: true),
      intensity: row.intensity,
      source: StrikeSource.values.byName(row.source),
    );
  }

  db.StrikesCompanion _toCompanion(Strike strike) {
    return db.StrikesCompanion.insert(
      id: strike.id,
      lat: strike.lat,
      lon: strike.lon,
      timestampMillis: strike.timestamp.millisecondsSinceEpoch,
      intensity: Value(strike.intensity),
      source: strike.source.name,
    );
  }

  Stream<List<Strike>> _pollRecent({
    required Duration window,
    required Duration refresh,
  }) async* {
    while (true) {
      final now = DateTime.now().toUtc();
      final from = now.subtract(window);
      final rows = await _database.strikesDao.listBetween(from: from, to: now);
      yield rows.map(_toDomain).toList(growable: false);
      await Future.delayed(refresh);
    }
  }
}

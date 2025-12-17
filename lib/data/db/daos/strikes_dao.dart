import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/strikes.dart';

part 'strikes_dao.g.dart';

@DriftAccessor(tables: [Strikes])
class StrikesDao extends DatabaseAccessor<AppDatabase> with _$StrikesDaoMixin {
  StrikesDao(super.db);

  Future<void> upsertStrike(StrikesCompanion strike) async {
    await into(strikes).insertOnConflictUpdate(strike);
  }

  Future<void> upsertStrikes(List<StrikesCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(strikes, items);
    });
  }

  Stream<List<Strike>> watchRecent({required DateTime since}) {
    final sinceMillis = since.millisecondsSinceEpoch;
    return (select(strikes)
          ..where((tbl) => tbl.timestampMillis.isBiggerOrEqualValue(sinceMillis))
          ..orderBy([(t) => OrderingTerm.desc(t.timestampMillis)]))
        .watch();
  }

  Future<List<Strike>> listBetween({
    required DateTime from,
    required DateTime to,
  }) {
    final fromMillis = from.millisecondsSinceEpoch;
    final toMillis = to.millisecondsSinceEpoch;
    return (select(strikes)
          ..where(
            (tbl) =>
                tbl.timestampMillis.isBetweenValues(fromMillis, toMillis),
          ))
        .get();
  }

  Future<int> deleteOlderThan(DateTime cutoff) {
    return (delete(strikes)
          ..where(
            (tbl) => tbl.timestampMillis.isSmallerThanValue(
              cutoff.millisecondsSinceEpoch,
            ),
          ))
        .go();
  }
}


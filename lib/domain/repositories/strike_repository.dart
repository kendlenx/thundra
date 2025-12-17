import '../models/strike.dart';

abstract interface class StrikeRepository {
  Stream<List<Strike>> watchRecent({required Duration window});
  Stream<List<Strike>> watchSince({required DateTime sinceUtc});

  Future<List<Strike>> listBetween({
    required DateTime from,
    required DateTime to,
  });

  Future<void> upsertStrike(Strike strike);
  Future<void> upsertStrikes(List<Strike> strikes);

  Future<int> purgeOlderThan(DateTime cutoffUtc);
}

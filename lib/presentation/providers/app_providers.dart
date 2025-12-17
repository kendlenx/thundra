import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/lightning_datasource.dart';
import '../../data/datasources/mock_lightning_datasource.dart';
import '../../data/datasources/placeholder_network_datasource.dart';
import '../../data/db/app_database.dart' hide Strike;
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/strike_repository.dart';
import '../../domain/models/strike.dart';
import '../../domain/repositories/strike_repository.dart';
import 'user_location_notifier.dart';
import '../alerts/alerts_controller.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final strikeRepositoryProvider = Provider<StrikeRepository>((ref) {
  return DriftStrikeRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final lightningDataSourceProvider = Provider<LightningDataSource>((ref) {
  const useNetwork =
      bool.fromEnvironment('THUNDRA_USE_NETWORK_DATASOURCE', defaultValue: false);

  final ds = useNetwork
      ? const PlaceholderNetworkDataSource()
      : MockLightningDataSource();

  unawaited(ds.start());
  ref.onDispose(ds.stop);
  return ds;
});

final strikeIngestionProvider = Provider<void>((ref) {
  final repo = ref.watch(strikeRepositoryProvider);
  final ds = ref.watch(lightningDataSourceProvider);
  final sub = ds.strikesStream().listen((Strike strike) async {
    await repo.upsertStrike(strike);
  });
  ref.onDispose(sub.cancel);
});

final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(alertSettingsProvider.future);
  await ref.read(userLocationProvider.notifier).warmup();
  ref.read(strikeIngestionProvider);

  // Keep a rolling window of data locally.
  await ref
      .read(strikeRepositoryProvider)
      .purgeOlderThan(DateTime.now().toUtc().subtract(const Duration(days: 30)));
});

final strikeRetentionProvider = Provider<void>((ref) {
  final repo = ref.watch(strikeRepositoryProvider);

  Future<void> purge() async {
    await repo.purgeOlderThan(
      DateTime.now().toUtc().subtract(const Duration(days: 30)),
    );
  }

  unawaited(purge());
  final timer = Timer.periodic(const Duration(hours: 6), (_) => unawaited(purge()));
  ref.onDispose(timer.cancel);
});

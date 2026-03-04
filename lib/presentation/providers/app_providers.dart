import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/lightning_datasource.dart';
import '../../data/datasources/blitzortung_lightning_datasource.dart';
import '../../data/datasources/mock_lightning_datasource.dart';
import '../../data/db/app_database.dart' hide Strike;
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/strike_repository.dart';
import '../../domain/models/strike.dart';
import '../../domain/repositories/strike_repository.dart';
import 'user_location_notifier.dart';
import '../alerts/alerts_controller.dart';
import '../growth/growth_service.dart';
import '../review/review_prompt_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final growthServiceProvider = FutureProvider<GrowthService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final service = GrowthService(prefs);
  ref.onDispose(service.dispose);
  return service;
});

final growthStartupProvider = FutureProvider<void>((ref) async {
  final growth = await ref.watch(growthServiceProvider.future);
  await growth.start();
});

final reviewPromptServiceProvider = FutureProvider<ReviewPromptService>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ReviewPromptService(prefs);
});

final strikeRepositoryProvider = Provider<StrikeRepository>((ref) {
  return DriftStrikeRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final lightningDataSourceProvider = Provider<LightningDataSource>((ref) {
  const useNetwork = bool.fromEnvironment(
    'THUNDRA_USE_NETWORK_DATASOURCE',
    defaultValue: false,
  );

  final ds = useNetwork
      ? BlitzortungLightningDataSource()
      : MockLightningDataSource();

  unawaited(ds.start());
  ref.onDispose(ds.stop);
  return ds;
});

final strikeIngestionProvider = Provider<void>((ref) {
  final repo = ref.watch(strikeRepositoryProvider);
  final ds = ref.watch(lightningDataSourceProvider);
  final pending = <Strike>[];
  Timer? flushTimer;
  var flushing = false;
  late void Function() scheduleFlush;

  Future<void> flush() async {
    if (flushing || pending.isEmpty) return;
    flushing = true;
    final batch = List<Strike>.from(pending);
    pending.clear();
    try {
      await repo.upsertStrikes(batch);
    } finally {
      flushing = false;
      if (pending.isNotEmpty) scheduleFlush();
    }
  }

  scheduleFlush = () {
    flushTimer ??= Timer(const Duration(milliseconds: 500), () {
      flushTimer = null;
      unawaited(flush());
    });
  };

  final sub = ds.strikesStream().listen((Strike strike) {
    pending.add(strike);
    if (pending.length >= 50) {
      unawaited(flush());
    } else {
      scheduleFlush();
    }
  });
  ref.onDispose(() {
    flushTimer?.cancel();
    unawaited(flush());
    sub.cancel();
  });
});

final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(alertSettingsProvider.future);
  await ref.read(userLocationProvider.notifier).warmup();
  ref.read(strikeIngestionProvider);

  // Keep a rolling window of data locally.
  await ref
      .read(strikeRepositoryProvider)
      .purgeOlderThan(
        DateTime.now().toUtc().subtract(const Duration(days: 30)),
      );
});

final strikeRetentionProvider = Provider<void>((ref) {
  final repo = ref.watch(strikeRepositoryProvider);

  Future<void> purge() async {
    await repo.purgeOlderThan(
      DateTime.now().toUtc().subtract(const Duration(days: 30)),
    );
  }

  unawaited(purge());
  final timer = Timer.periodic(
    const Duration(hours: 6),
    (_) => unawaited(purge()),
  );
  ref.onDispose(timer.cancel);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/alert_settings.dart';
import '../providers/app_providers.dart';

final alertSettingsProvider =
    AsyncNotifierProvider<AlertSettingsController, AlertSettings>(
  AlertSettingsController.new,
);

class AlertSettingsController extends AsyncNotifier<AlertSettings> {
  @override
  Future<AlertSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final current = await repo.getAlertSettings();
    // Ensure the row exists (single-row table keyed by id=1).
    await repo.saveAlertSettings(current);
    return current;
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: enabled,
      radiusKm: current.radiusKm,
      windowMinutes: current.windowMinutes,
      quietHoursEnabled: current.quietHoursEnabled,
      quietStartMinutes: current.quietStartMinutes,
      quietEndMinutes: current.quietEndMinutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }

  Future<void> setRadiusKm(int km) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: current.enabled,
      radiusKm: km,
      windowMinutes: current.windowMinutes,
      quietHoursEnabled: current.quietHoursEnabled,
      quietStartMinutes: current.quietStartMinutes,
      quietEndMinutes: current.quietEndMinutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }

  Future<void> setWindowMinutes(int minutes) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: current.enabled,
      radiusKm: current.radiusKm,
      windowMinutes: minutes,
      quietHoursEnabled: current.quietHoursEnabled,
      quietStartMinutes: current.quietStartMinutes,
      quietEndMinutes: current.quietEndMinutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }

  Future<void> setQuietHoursEnabled(bool enabled) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: current.enabled,
      radiusKm: current.radiusKm,
      windowMinutes: current.windowMinutes,
      quietHoursEnabled: enabled,
      quietStartMinutes: current.quietStartMinutes,
      quietEndMinutes: current.quietEndMinutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }

  Future<void> setQuietStartMinutes(int minutes) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: current.enabled,
      radiusKm: current.radiusKm,
      windowMinutes: current.windowMinutes,
      quietHoursEnabled: current.quietHoursEnabled,
      quietStartMinutes: minutes,
      quietEndMinutes: current.quietEndMinutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }

  Future<void> setQuietEndMinutes(int minutes) async {
    final current = state.value ?? AlertSettings.defaults;
    final updated = AlertSettings(
      enabled: current.enabled,
      radiusKm: current.radiusKm,
      windowMinutes: current.windowMinutes,
      quietHoursEnabled: current.quietHoursEnabled,
      quietStartMinutes: current.quietStartMinutes,
      quietEndMinutes: minutes,
    );
    state = AsyncValue.data(updated);
    await ref.read(settingsRepositoryProvider).saveAlertSettings(updated);
  }
}

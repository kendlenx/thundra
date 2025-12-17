import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/models/alert_settings.dart';
import '../../domain/models/strike.dart';
import '../../domain/services/distance.dart';
import 'alerts_controller.dart';
import 'local_notifications_service.dart';
import '../providers/app_providers.dart';

class AlertEvent {
  const AlertEvent({
    required this.occurredAt,
    required this.radiusKm,
    required this.closestKm,
    required this.countWithinRadius,
  });

  final DateTime occurredAt;
  final int radiusKm;
  final double closestKm;
  final int countWithinRadius;
}

class AlertState {
  const AlertState({
    required this.enabled,
    required this.isQuietHours,
    required this.locationGranted,
    required this.lastEvent,
  });

  final bool enabled;
  final bool isQuietHours;
  final bool locationGranted;
  final AlertEvent? lastEvent;

  static const initial = AlertState(
    enabled: false,
    isQuietHours: false,
    locationGranted: false,
    lastEvent: null,
  );
}

final alertStateProvider = NotifierProvider<AlertsEngine, AlertState>(
  AlertsEngine.new,
);

class AlertsEngine extends Notifier<AlertState> {
  static const _cooldown = Duration(minutes: 5);
  static const _tick = Duration(seconds: 5);
  static const _positionCacheTtl = Duration(seconds: 30);

  Timer? _timer;
  StreamSubscription<List<Strike>>? _sub;
  ProviderSubscription<AsyncValue<AlertSettings>>? _settingsSub;
  List<Strike> _latestStrikes = const [];

  DateTime? _lastTriggeredAtUtc;
  double? _lastTriggeredClosestKm;
  Position? _cachedPos;
  DateTime? _cachedPosAtUtc;

  @override
  AlertState build() {
    ref.onDispose(_stop);
    _start();
    return AlertState.initial;
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _evaluate());

    _sub?.cancel();
    // Use a rolling window to avoid unbounded growth over long sessions.
    _sub = ref
        .read(strikeRepositoryProvider)
        .watchRecent(window: const Duration(hours: 1))
        .listen((strikes) {
      _latestStrikes = strikes;
      _evaluate();
    });

    _settingsSub?.close();
    _settingsSub = ref.listen<AsyncValue<AlertSettings>>(
      alertSettingsProvider,
      (previous, next) => _evaluate(),
    );
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _sub?.cancel();
    _sub = null;
    _settingsSub?.close();
    _settingsSub = null;
    _cachedPos = null;
    _cachedPosAtUtc = null;
  }

  Future<void> _evaluate() async {
    final settings = ref.read(alertSettingsProvider).valueOrNull ?? AlertSettings.defaults;
    final enabled = settings.enabled;

    final nowLocal = DateTime.now();
    final isQuiet = _isInQuietHours(settings: settings, nowLocal: nowLocal);

    final permission = await Geolocator.checkPermission();
    final granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    state = AlertState(
      enabled: enabled,
      isQuietHours: isQuiet,
      locationGranted: granted,
      lastEvent: state.lastEvent,
    );

    if (!enabled) return;
    if (isQuiet) return;
    if (!granted) return;

    final nowUtc = DateTime.now().toUtc();
    final pos = await _getPosition(nowUtc: nowUtc);
    if (pos == null) return;

    final cutoff = nowUtc.subtract(Duration(minutes: settings.windowMinutes));

    var count = 0;
    var closest = double.infinity;
    for (final s in _latestStrikes) {
      if (s.timestamp.isBefore(cutoff)) continue;
      final km = haversineKm(
        lat1: pos.latitude,
        lon1: pos.longitude,
        lat2: s.lat,
        lon2: s.lon,
      );
      if (km <= settings.radiusKm) {
        count += 1;
        if (km < closest) closest = km;
      }
    }

    if (count == 0) return;

    final shouldTrigger = _shouldTrigger(nowUtc: nowUtc, closestKm: closest);
    if (!shouldTrigger) return;

    _lastTriggeredAtUtc = nowUtc;
    _lastTriggeredClosestKm = closest;

    final event = AlertEvent(
      occurredAt: nowLocal,
      radiusKm: settings.radiusKm,
      closestKm: closest,
      countWithinRadius: count,
    );
    state = AlertState(
      enabled: enabled,
      isQuietHours: isQuiet,
      locationGranted: granted,
      lastEvent: event,
    );

    await ref.read(localNotificationsServiceProvider).showLightningAlert(
          radiusKm: settings.radiusKm,
          closestKm: closest,
        );

    await ref.read(settingsRepositoryProvider).insertAlertEvent(
          triggeredAtLocal: nowLocal,
          distanceKm: closest,
          radiusKm: settings.radiusKm,
        );
  }

  bool _shouldTrigger({required DateTime nowUtc, required double closestKm}) {
    final lastAt = _lastTriggeredAtUtc;
    if (lastAt == null) return true;

    final elapsed = nowUtc.difference(lastAt);
    if (elapsed >= _cooldown) return true;

    final lastClosest = _lastTriggeredClosestKm;
    if (lastClosest == null) return true;

    // Allow a new alert inside the cooldown if it is meaningfully closer.
    return closestKm <= (lastClosest - 0.5);
  }

  bool _isInQuietHours({required AlertSettings settings, required DateTime nowLocal}) {
    if (!settings.quietHoursEnabled) return false;

    final minutes = nowLocal.hour * 60 + nowLocal.minute;
    final start = settings.quietStartMinutes;
    final end = settings.quietEndMinutes;

    if (start == end) return true;
    if (start < end) return minutes >= start && minutes < end;
    return minutes >= start || minutes < end; // wraps midnight
  }

  Future<Position?> _getPosition({required DateTime nowUtc}) async {
    final cachedAt = _cachedPosAtUtc;
    final cachedPos = _cachedPos;
    if (cachedAt != null &&
        cachedPos != null &&
        nowUtc.difference(cachedAt) < _positionCacheTtl) {
      return cachedPos;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      _cachedPos = pos;
      _cachedPosAtUtc = nowUtc;
      return pos;
    } catch (_) {
      return null;
    }
  }
}

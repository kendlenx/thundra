import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/models/strike.dart';
import '../../domain/services/distance.dart';
import '../alerts/alerts_controller.dart';
import 'app_providers.dart';
import 'user_location_notifier.dart';

/// Syncs nearby lightning context to the Apple Watch via a MethodChannel.
///
/// Channel: `thundra/watch_sync`
/// Method: `updateContext`
/// Payload:
/// ```
/// {
///   "nearbyStrikeCount": 3,
///   "isActive": true,
///   "radiusKm": 10,
///   "windowMin": 10,
///   "updatedAt": "2025-12-18T00:53:00Z"
/// }
/// ```
final watchSyncServiceProvider = Provider<WatchSyncService>((ref) {
  final service = WatchSyncService(ref);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

class WatchSyncService {
  WatchSyncService(this._ref);

  static const _channel = MethodChannel('thundra/watch_sync');
  static const _interval = Duration(seconds: 8);

  final Ref _ref;
  Timer? _timer;
  Map<String, Object?>? _lastPayload;
  bool _busy = false;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _tick());
    Future<void>.delayed(const Duration(seconds: 2), _tick);
  }

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final settings = await _ref.read(alertSettingsProvider.future);
      final pos = await _position();
      if (pos == null) {
        _busy = false;
        return;
      }

      final now = DateTime.now().toUtc();
      final strikes = await _recentStrikes(
        windowMinutes: settings.windowMinutes,
        nowUtc: now,
      );
      final nearby = _countWithin(
        strikes: strikes,
        pos: pos,
        radiusKm: settings.radiusKm.toDouble(),
      );

      final payload = <String, Object?>{
        'nearbyStrikeCount': nearby,
        'isActive': nearby > 0,
        'radiusKm': settings.radiusKm,
        'windowMin': settings.windowMinutes,
        'updatedAt': now.toIso8601String(),
      };

      if (payload != _lastPayload) {
        await _channel.invokeMethod('updateContext', payload);
        _lastPayload = payload;
      }
    } catch (_) {
      // best-effort; avoid noisy logs
    } finally {
      _busy = false;
    }
  }

  Future<Position?> _position() async {
    final cached = _ref.read(userLocationProvider).valueOrNull;
    if (cached != null) return cached;
    try {
      return await _ref.read(userLocationProvider.notifier).requestAndFetch();
    } catch (_) {
      return null;
    }
  }

  Future<List<Strike>> _recentStrikes({
    required int windowMinutes,
    required DateTime nowUtc,
  }) {
    final repo = _ref.read(strikeRepositoryProvider);
    return repo.listBetween(
      from: nowUtc.subtract(Duration(minutes: windowMinutes)),
      to: nowUtc,
    );
  }

  int _countWithin({
    required List<Strike> strikes,
    required Position pos,
    required double radiusKm,
  }) {
    var count = 0;
    for (final s in strikes) {
      final km = haversineKm(
        lat1: pos.latitude,
        lon1: pos.longitude,
        lat2: s.lat,
        lon2: s.lon,
      );
      if (km <= radiusKm) count++;
    }
    return count;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

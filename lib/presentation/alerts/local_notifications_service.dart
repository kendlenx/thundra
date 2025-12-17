import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localNotificationsServiceProvider =
    Provider<LocalNotificationsService>((ref) {
  final service = LocalNotificationsService();
  ref.onDispose(service.dispose);
  return service;
});

class LocalNotificationsService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const init = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
      ),
    );
    await _plugin.initialize(init);
    _initialized = true;
  }

  Future<void> showLightningAlert({
    required int radiusKm,
    required double closestKm,
  }) async {
    await _ensureInitialized();
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
        presentBadge: false,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    await _plugin.show(
      1001,
      'Lightning nearby',
      'Lightning detected within ${radiusKm}km (closest ${closestKm.toStringAsFixed(1)}km). Stay aware.',
      details,
    );
  }

  Future<void> requestIosPermissions() async {
    await _ensureInitialized();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: false, sound: false);
  }

  Future<void> dispose() async {}
}

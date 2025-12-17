class AlertSettings {
  const AlertSettings({
    required this.enabled,
    required this.radiusKm,
    required this.windowMinutes,
    required this.quietHoursEnabled,
    required this.quietStartMinutes,
    required this.quietEndMinutes,
  });

  final bool enabled;
  final int radiusKm; // 5/10/25
  final int windowMinutes; // 10/30
  final bool quietHoursEnabled;

  /// Minutes since midnight local time.
  final int quietStartMinutes;
  final int quietEndMinutes;

  static const defaults = AlertSettings(
    enabled: false,
    radiusKm: 10,
    windowMinutes: 10,
    quietHoursEnabled: false,
    quietStartMinutes: 22 * 60,
    quietEndMinutes: 7 * 60,
  );
}

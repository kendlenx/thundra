import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../alerts/alerts_controller.dart';
import '../alerts/local_notifications_service.dart';
import '../providers/user_location_notifier.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _locationGranted = false;
  bool _notificationsGranted = false;
  LocationPermission? _locationPermission;
  PermissionStatus? _notificationStatus;

  @override
  void initState() {
    super.initState();
    _refreshLocationStatus();
    _refreshNotificationStatus();
  }

  Future<void> _refreshLocationStatus() async {
    final permission = await Geolocator.checkPermission();
    final granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!mounted) return;
    setState(() {
      _locationGranted = granted;
      _locationPermission = permission;
    });
  }

  Future<void> _refreshNotificationStatus() async {
    final status = await Permission.notification.status;
    final granted =
        status.isGranted || status.isLimited || status.isProvisional;
    if (!mounted) return;
    setState(() {
      _notificationsGranted = granted;
      _notificationStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Calm alerts. Clear skies.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Track lightning live, stay aware with gentle alerts, '
                'and review trends over time. Enable what you want now; '
                'you can change it later.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 18),
              _FeatureCard(
                icon: CupertinoIcons.bolt_fill,
                title: 'Live map',
                subtitle: 'See strikes as they happen with gentle fade-outs.',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: CupertinoIcons.bell_fill,
                title: 'Calm alerts',
                subtitle: 'Get notified only when lightning is nearby.',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: CupertinoIcons.chart_bar_fill,
                title: 'Stats & heatmaps',
                subtitle: 'Understand patterns over hours, days, and months.',
              ),
              const Spacer(),
              _PermissionRow(
                title: 'Location',
                subtitle: _locationGranted
                    ? 'Granted'
                    : 'Only used to measure distance for alerts.',
                enabled: _locationGranted,
                actionLabel: _locationActionLabel(),
                onPressed: _locationGranted ? null : _requestLocation,
              ),
              const SizedBox(height: 12),
              _PermissionRow(
                title: 'Notifications',
                subtitle: _notificationsGranted
                    ? 'Granted'
                    : 'Used for local alerts only.',
                enabled: _notificationsGranted,
                actionLabel: _notificationActionLabel(),
                onPressed: _notificationsGranted ? null : _requestNotifications,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => ref
                        .read(onboardingProvider.notifier)
                        .complete(
                          source: 'not_now',
                          locationGranted: _locationGranted,
                          notificationsGranted: _notificationsGranted,
                        ),
                    child: const Text(
                      'Not now',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton.filled(
                    onPressed: () => ref
                        .read(onboardingProvider.notifier)
                        .complete(
                          source: 'start_exploring',
                          locationGranted: _locationGranted,
                          notificationsGranted: _notificationsGranted,
                        ),
                    child: const Text('Start exploring'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _locationActionLabel() {
    if (_locationGranted) return 'Enabled';
    if (_locationPermission == LocationPermission.deniedForever) {
      return 'Settings';
    }
    return 'Enable';
  }

  String _notificationActionLabel() {
    if (_notificationsGranted) return 'Enabled';
    if (_notificationStatus?.isPermanentlyDenied == true) {
      return 'Settings';
    }
    return 'Enable';
  }

  Future<void> _requestLocation() async {
    HapticFeedback.lightImpact();
    final proceed = await _confirmPermission(
      context,
      title: 'Enable location',
      message:
          'THUNDRA uses your location to measure distance for alerts. '
          'We do not store or share your location.',
      actionLabel: _locationPermission == LocationPermission.deniedForever
          ? 'Open Settings'
          : 'Continue',
    );
    if (!proceed) return;
    if (_locationPermission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      await _refreshLocationStatus();
      return;
    }
    await ref.read(userLocationProvider.notifier).requestAndFetch();
    await _refreshLocationStatus();
  }

  Future<void> _requestNotifications() async {
    HapticFeedback.lightImpact();
    final proceed = await _confirmPermission(
      context,
      title: 'Enable notifications',
      message:
          'We use local notifications to alert you when lightning is nearby. '
          'No data is sent to servers.',
      actionLabel: _notificationStatus?.isPermanentlyDenied == true
          ? 'Open Settings'
          : 'Continue',
    );
    if (!proceed) return;
    if (_notificationStatus?.isPermanentlyDenied == true) {
      await openAppSettings();
      await _refreshNotificationStatus();
      return;
    }
    final ok = await ref
        .read(localNotificationsServiceProvider)
        .requestIosPermissions();
    if (!mounted) return;
    if (ok == true) {
      await ref.read(alertSettingsProvider.notifier).setEnabled(true);
    }
    await _refreshNotificationStatus();
  }
}

Future<bool> _confirmPermission(
  BuildContext context, {
  required String title,
  required String message,
  required String actionLabel,
}) async {
  var confirmed = false;
  await showCupertinoDialog<void>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
            child: Text(actionLabel),
          ),
        ],
      );
    },
  );
  return confirmed;
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnightRaised,
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.stroke.withValues(alpha: 0.6)
                      : AppColors.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnightRaised,
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

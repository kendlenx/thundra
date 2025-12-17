import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/user_location_notifier.dart';
import '../widgets/thundra_card.dart';
import 'alerts_controller.dart';
import 'alerts_engine.dart';
import 'local_notifications_service.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep engine alive while Alerts tab is in the tree.
    ref.watch(alertStateProvider);

    final settingsAsync = ref.watch(alertSettingsProvider);
    final engine = ref.watch(alertStateProvider);
    final df = DateFormat('MMM d, HH:mm');

    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.midnightRaised,
        border: Border(bottom: BorderSide(color: AppColors.separator)),
        middle: Text('Alerts'),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ThundraCard(
              child: settingsAsync.when(
                loading: () => const CupertinoActivityIndicator(radius: 10),
                error: (error, stackTrace) =>
                    const Text('Failed to load settings.'),
                data: (s) => Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Alerts enabled',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: s.enabled,
                        activeTrackColor: AppColors.accent.withValues(alpha: 0.45),
                      onChanged: (v) async {
                        HapticFeedback.lightImpact();
                        if (v) {
                          final proceed = await _confirmEnable(context);
                          if (!proceed) return;
                          await ref
                              .read(localNotificationsServiceProvider)
                              .requestIosPermissions();
                          await ref
                              .read(userLocationProvider.notifier)
                              .requestAndFetch();
                        }
                        await ref
                            .read(alertSettingsProvider.notifier)
                            .setEnabled(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ThundraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radius',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  settingsAsync.when(
                    data: (s) => _IntSegmented(
                      values: const [5, 10, 25],
                      label: (v) => '${v}km',
                      selected: s.radiusKm,
                      onChanged: (v) => ref
                          .read(alertSettingsProvider.notifier)
                          .setRadiusKm(v),
                    ),
                    loading: () => const CupertinoActivityIndicator(radius: 10),
                    error: (error, stackTrace) =>
                        const Text('Failed to load settings.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ThundraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time window',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  settingsAsync.when(
                    data: (s) => _IntSegmented(
                      values: const [10, 30],
                      label: (v) => '${v}m',
                      selected: s.windowMinutes,
                      onChanged: (v) => ref
                          .read(alertSettingsProvider.notifier)
                          .setWindowMinutes(v),
                    ),
                    loading: () => const CupertinoActivityIndicator(radius: 10),
                    error: (error, stackTrace) =>
                        const Text('Failed to load settings.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ThundraCard(
              child: settingsAsync.when(
                loading: () => const CupertinoActivityIndicator(radius: 10),
                error: (error, stackTrace) =>
                    const Text('Failed to load settings.'),
                data: (s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Quiet hours',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: s.quietHoursEnabled,
                          activeTrackColor:
                              AppColors.accent.withValues(alpha: 0.45),
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(alertSettingsProvider.notifier)
                                .setQuietHoursEnabled(v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (s.quietHoursEnabled)
                      Row(
                        children: [
                          Expanded(
                            child: _TimeButton(
                              label: 'Start',
                              minutes: s.quietStartMinutes,
                              onTap: () async {
                                final picked = await _pickTimeMinutes(
                                  context,
                                  initialMinutes: s.quietStartMinutes,
                                );
                                if (picked == null) return;
                                await ref
                                    .read(alertSettingsProvider.notifier)
                                    .setQuietStartMinutes(picked);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TimeButton(
                              label: 'End',
                              minutes: s.quietEndMinutes,
                              onTap: () async {
                                final picked = await _pickTimeMinutes(
                                  context,
                                  initialMinutes: s.quietEndMinutes,
                                );
                                if (picked == null) return;
                                await ref
                                    .read(alertSettingsProvider.notifier)
                                    .setQuietEndMinutes(picked);
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      'Quiet hours suppress notifications while still monitoring in the background when possible.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ThundraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusRow(
                    label: 'Monitoring',
                    value: engine.enabled ? 'ON' : 'OFF',
                    valueColor: engine.enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Location',
                    value: engine.locationGranted ? 'Granted' : 'Denied',
                    valueColor: engine.locationGranted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Quiet hours',
                    value: engine.isQuietHours ? 'Active' : 'Inactive',
                    valueColor: engine.isQuietHours
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Last alert',
                    value: engine.lastEvent == null
                        ? '—'
                        : df.format(engine.lastEvent!.occurredAt),
                    valueColor: engine.lastEvent == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  if (!engine.locationGranted)
                    const Text(
                      'Alerts require location permission to measure distance. You can still browse the map without enabling alerts.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.midnightRaised,
          border: Border.all(color: AppColors.separator),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '$h:$m',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                CupertinoIcons.chevron_down,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntSegmented extends StatelessWidget {
  const _IntSegmented({
    required this.values,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final List<int> values;
  final String Function(int) label;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.midnightRaised,
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selected,
        thumbColor: AppColors.accent.withValues(alpha: 0.24),
        backgroundColor: CupertinoColors.transparent,
        children: {
          for (final v in values)
            v: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(label(v)),
            ),
        },
        onValueChanged: (v) {
          if (v == null) return;
          HapticFeedback.lightImpact();
          onChanged(v);
        },
      ),
    );
  }
}

Future<bool> _confirmEnable(BuildContext context) async {
  var confirmed = false;
  await showCupertinoDialog<void>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Enable alerts'),
        content: const Text(
          'THUNDRA can use your location to check distance and send calm local notifications when lightning is nearby. You can change this anytime.',
        ),
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
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
  return confirmed;
}

Future<int?> _pickTimeMinutes(
  BuildContext context, {
  required int initialMinutes,
}) async {
  var selectedMinutes = initialMinutes;
  final initial = DateTime(2000, 1, 1, initialMinutes ~/ 60, initialMinutes % 60);
  var canceled = true;

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return Container(
        height: 320,
        color: AppColors.midnightRaised,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.separator)),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      canceled = true;
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      canceled = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initial,
                use24hFormat: true,
                onDateTimeChanged: (dt) {
                  selectedMinutes = dt.hour * 60 + dt.minute;
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  return canceled ? null : selectedMinutes;
}

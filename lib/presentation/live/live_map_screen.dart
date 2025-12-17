import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../core/theme/app_colors.dart';
import '../../domain/models/strike.dart';
import '../providers/user_location_notifier.dart';
import '../widgets/thundra_card.dart';
import '../widgets/thundra_map.dart';
import 'google_dark_map_style.dart';
import 'live_map_controller.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  // Default to the free map so the app runs on iOS Simulator with no API keys.
  static const bool _useGoogleMaps =
      bool.fromEnvironment('THUNDRA_USE_GOOGLE_MAPS', defaultValue: false);

  final _flutterMapController = MapController();
  gmaps.GoogleMapController? _googleController;
  double _googleZoom = 2.4;

  @override
  Widget build(BuildContext context) {
    final windowMinutes = ref.watch(liveWindowMinutesProvider);
    final strikesAsync = ref.watch(liveStrikesProvider);
    final strikes = strikesAsync.value ?? const <Strike>[];
    final visibleStrikes = _capRecent(strikes, max: _useGoogleMaps ? 450 : 900);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      child: Stack(
        children: [
          Positioned.fill(
            child: _useGoogleMaps
                ? _GoogleLiveMap(
                    strikes: visibleStrikes,
                    windowMinutes: windowMinutes,
                    zoom: _googleZoom,
                    onMapCreated: (c) async {
                      _googleController = c;
                    },
                    onCameraMove: (pos) {
                      // Avoid rebuild spam.
                      if ((pos.zoom - _googleZoom).abs() < 0.05) return;
                      setState(() => _googleZoom = pos.zoom);
                    },
                  )
                : ThundraMap(
                    mapController: _flutterMapController,
                    layers: [
                      CircleLayer(
                        circles: visibleStrikes
                            .map((s) => _toFlutterCircle(
                                  strike: s,
                                  window: Duration(minutes: windowMinutes),
                                ))
                            .toList(growable: false),
                      ),
                    ],
                  ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: (strikesAsync.hasValue && visibleStrikes.isEmpty)
                    ? const _EmptyOverlay(
                        key: ValueKey('empty'),
                        title: 'No strikes in this window',
                        subtitle: 'Try a longer time window.',
                      )
                    : const SizedBox.shrink(key: ValueKey('non-empty')),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'THUNDRA',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    _RoundIconButton(
                      icon: CupertinoIcons.location_fill,
                      onPressed: _centerOnUser,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 62,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _RoundIconButton(
                    icon: CupertinoIcons.plus,
                    onPressed: _zoomIn,
                  ),
                  const SizedBox(height: 10),
                  _RoundIconButton(
                    icon: CupertinoIcons.minus,
                    onPressed: _zoomOut,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: ThundraCard(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.stroke.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Last $windowMinutes min · ${visibleStrikes.length} strikes',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        strikesAsync.isLoading
                            ? const CupertinoActivityIndicator(radius: 9)
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _WindowSegmentedControl(
                      selectedMinutes: windowMinutes,
                      onChanged: (m) {
                        HapticFeedback.lightImpact();
                        ref.read(liveWindowMinutesProvider.notifier).state = m;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CircleMarker _toFlutterCircle({
    required Strike strike,
    required Duration window,
  }) {
    final age = DateTime.now().toUtc().difference(strike.timestamp);
    final t = (age.inMilliseconds / window.inMilliseconds).clamp(0.0, 1.0);
    final opacity = (1.0 - t) * (1.0 - t);
    return CircleMarker(
      point: ll.LatLng(strike.lat, strike.lon),
      radius: 5.5,
      color: AppColors.accent.withValues(alpha: opacity * 0.50),
      borderColor: AppColors.accent.withValues(alpha: opacity * 0.85),
      borderStrokeWidth: 1.0,
      useRadiusInMeter: false,
    );
  }

  Future<void> _centerOnUser() async {
    final position =
        await ref.read(userLocationProvider.notifier).requestAndFetch();
    if (position == null) return;

    if (_useGoogleMaps && _googleController != null) {
      await _googleController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(position.latitude, position.longitude),
          6.8,
        ),
      );
      return;
    }

    _flutterMapController.move(
      ll.LatLng(position.latitude, position.longitude),
      math.max(6.5, _flutterMapController.camera.zoom),
    );
  }

  Future<void> _zoomIn() async {
    HapticFeedback.selectionClick();
    if (_useGoogleMaps && _googleController != null) {
      await _googleController!.animateCamera(gmaps.CameraUpdate.zoomIn());
      return;
    }
    final cam = _flutterMapController.camera;
    _flutterMapController.move(cam.center, (cam.zoom + 1).clamp(1.0, 18.0));
  }

  Future<void> _zoomOut() async {
    HapticFeedback.selectionClick();
    if (_useGoogleMaps && _googleController != null) {
      await _googleController!.animateCamera(gmaps.CameraUpdate.zoomOut());
      return;
    }
    final cam = _flutterMapController.camera;
    _flutterMapController.move(cam.center, (cam.zoom - 1).clamp(1.0, 18.0));
  }

  List<Strike> _capRecent(List<Strike> strikes, {required int max}) {
    if (strikes.length <= max) return strikes;
    final sorted = List<Strike>.of(strikes)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(max).toList(growable: false);
  }
}

class _GoogleLiveMap extends StatelessWidget {
  const _GoogleLiveMap({
    required this.strikes,
    required this.windowMinutes,
    required this.zoom,
    required this.onMapCreated,
    required this.onCameraMove,
  });

  final List<Strike> strikes;
  final int windowMinutes;
  final double zoom;
  final ValueChanged<gmaps.GoogleMapController> onMapCreated;
  final ValueChanged<gmaps.CameraPosition> onCameraMove;

  @override
  Widget build(BuildContext context) {
    final window = Duration(minutes: windowMinutes);
    final circles = <gmaps.Circle>{
      for (final s in strikes)
        gmaps.Circle(
          circleId: gmaps.CircleId(s.id),
          center: gmaps.LatLng(s.lat, s.lon),
          // Keep a consistent on-screen size across zoom levels.
          radius: _metersForPixels(lat: s.lat, zoom: zoom, pixels: 6.5)
              .clamp(1.0, 1500000.0),
          fillColor: AppColors.accent
              .withValues(alpha: _opacityFor(s.timestamp, window) * 0.35),
          strokeColor: AppColors.accent
              .withValues(alpha: _opacityFor(s.timestamp, window) * 0.75),
          strokeWidth: 1,
        ),
    };

    return gmaps.GoogleMap(
      initialCameraPosition: const gmaps.CameraPosition(
        target: gmaps.LatLng(20, 0),
        zoom: 2.4,
      ),
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
      style: thundraGoogleDarkMapStyle,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      circles: circles,
    );
  }

  double _opacityFor(DateTime ts, Duration window) {
    final age = DateTime.now().toUtc().difference(ts).inMilliseconds;
    final t = (age / window.inMilliseconds).clamp(0.0, 1.0);
    final o = (1.0 - t) * (1.0 - t);
    return o;
  }

  double _metersForPixels({
    required double lat,
    required double zoom,
    required double pixels,
  }) {
    // Approx meters-per-pixel at given latitude/zoom.
    final mpp = 156543.03392 *
        math.cos(lat * math.pi / 180.0) /
        math.pow(2.0, zoom);
    return pixels * mpp;
  }
}

class _WindowSegmentedControl extends StatelessWidget {
  const _WindowSegmentedControl({
    required this.selectedMinutes,
    required this.onChanged,
  });

  final int selectedMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = <int, Widget>{
      1: Text('1m'),
      5: Text('5m'),
      15: Text('15m'),
      60: Text('60m'),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.midnightRaised,
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedMinutes,
        thumbColor: AppColors.accent.withValues(alpha: 0.24),
        backgroundColor: CupertinoColors.transparent,
        children: items,
        onValueChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.midnightRaised.withValues(alpha: 0.85),
          border: Border.all(color: AppColors.separator),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Icon(icon, color: AppColors.textPrimary, size: 18),
        ),
      ),
    );
  }
}

class _EmptyOverlay extends StatelessWidget {
  const _EmptyOverlay({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardSolid.withValues(alpha: 0.75),
              border: Border.all(color: AppColors.separator),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

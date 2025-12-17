import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../core/theme/app_colors.dart';
import '../../domain/models/heat_bin.dart';
import '../widgets/thundra_card.dart';
import '../widgets/thundra_map.dart';
import '../live/google_dark_map_style.dart';
import 'heatmap_aggregator.dart';
import 'heatmap_controller.dart';

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  static const bool _useGoogleMaps =
      bool.fromEnvironment('THUNDRA_USE_GOOGLE_MAPS', defaultValue: false);

  final _flutterMapController = MapController();
  gmaps.GoogleMapController? _googleController;
  double _googleZoom = 2.4;

  HeatBin? _selected;

  @override
  Widget build(BuildContext context) {
    final window = ref.watch(heatmapWindowProvider);
    final binsAsync = ref.watch(heatBinsProvider);
    final bins = binsAsync.value ?? const <HeatBin>[];
    final visibleBins =
        bins.length > 1100 ? bins.take(1100).toList(growable: false) : bins;
    final maxCount = bins.isEmpty ? 0 : bins.first.count;

    final binsByKey = <String, HeatBin>{for (final b in visibleBins) b.key: b};

    return CupertinoPageScaffold(
      backgroundColor: AppColors.midnight,
      child: Stack(
        children: [
          Positioned.fill(
            child: _useGoogleMaps
                ? _GoogleHeatmap(
                    bins: visibleBins,
                    maxCount: maxCount,
                    zoom: _googleZoom,
                    onMapCreated: (c) {
                      _googleController = c;
                    },
                    onCameraMove: (pos) {
                      // Avoid rebuild spam.
                      if ((pos.zoom - _googleZoom).abs() < 0.05) return;
                      setState(() => _googleZoom = pos.zoom);
                    },
                    onTap: (p) {
                      final hit = _pickBinForTap(
                        point: p,
                        binsByKey: binsByKey,
                        binSize: ref.read(heatmapBinSizeProvider),
                      );
                      setState(() => _selected = hit);
                    },
                  )
                : ThundraMap(
                    mapController: _flutterMapController,
                    layers: [
                      CircleLayer(
                        circles: visibleBins
                            .map((b) => _toFlutterCircle(b, maxCount))
                            .toList(growable: false),
                      ),
                    ],
                    onTap: (tapPos, p) {
                      final hit = _pickBinForTap(
                        point: gmaps.LatLng(p.latitude, p.longitude),
                        binsByKey: binsByKey,
                        binSize: ref.read(heatmapBinSizeProvider),
                      );
                      setState(() => _selected = hit);
                    },
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
                child: (binsAsync.hasValue && visibleBins.isEmpty)
                    ? const _EmptyOverlay(
                        key: ValueKey('empty'),
                        title: 'No strikes for this window',
                        subtitle: 'Let it run for a bit or switch to All Time.',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heatmap',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _HeatmapWindowControl(
                      value: window,
                      onChanged: (w) {
                        HapticFeedback.lightImpact();
                        ref.read(heatmapWindowProvider.notifier).state = w;
                        setState(() => _selected = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    _Legend(maxCount: maxCount),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.10),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: _selected == null
                    ? const SizedBox.shrink(key: ValueKey('no-selection'))
                    : _SelectedBinCard(
                        key: ValueKey(_selected!.key),
                        selected: _selected!,
                        window: window,
                        onClose: () => setState(() => _selected = null),
                      ),
              ),
            ),
          ),
          if (binsAsync.isLoading)
            const Positioned(
              right: 16,
              bottom: 96,
              child: CupertinoActivityIndicator(radius: 10),
            ),
        ],
      ),
    );
  }

  HeatBin? _pickBinForTap({
    required gmaps.LatLng point,
    required Map<String, HeatBin> binsByKey,
    required double binSize,
  }) {
    final latBin = (point.latitude / binSize).floorToDouble() * binSize;
    final lonBin = (point.longitude / binSize).floorToDouble() * binSize;
    final key = '${latBin == 0 ? 0 : latBin},${lonBin == 0 ? 0 : lonBin}';
    return binsByKey[key];
  }

  CircleMarker _toFlutterCircle(HeatBin b, int maxCount) {
    final strength = HeatmapAggregator.normalizeCount(b.count, maxCount);
    final opacity = (0.06 + strength * 0.42).clamp(0.06, 0.55);
    final radius = 10 + strength * 22;
    return CircleMarker(
      point: ll.LatLng(b.lat, b.lon),
      color: AppColors.accent.withValues(alpha: opacity),
      borderColor: AppColors.accent.withValues(alpha: opacity * 0.7),
      borderStrokeWidth: 0.6,
      radius: radius,
      useRadiusInMeter: false,
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
}

class _SelectedBinCard extends StatelessWidget {
  const _SelectedBinCard({
    required this.selected,
    required this.window,
    required this.onClose,
    super.key,
  });

  final HeatBin selected;
  final HeatmapWindow window;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ThundraCard(
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.circle_filled,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This area: ${selected.count} strikes',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Window: ${windowLabel(window)}',
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
            minimumSize: const Size(32, 32),
            onPressed: onClose,
            child: const Icon(
              CupertinoIcons.xmark,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleHeatmap extends StatelessWidget {
  const _GoogleHeatmap({
    required this.bins,
    required this.maxCount,
    required this.zoom,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onTap,
  });

  final List<HeatBin> bins;
  final int maxCount;
  final double zoom;
  final ValueChanged<gmaps.GoogleMapController> onMapCreated;
  final ValueChanged<gmaps.CameraPosition> onCameraMove;
  final ValueChanged<gmaps.LatLng> onTap;

  @override
  Widget build(BuildContext context) {
    final circles = <gmaps.Circle>{};
    for (final b in bins) {
      final strength = HeatmapAggregator.normalizeCount(b.count, maxCount);
      final alpha = (0.05 + strength * 0.42).clamp(0.05, 0.55);
      // Keep a consistent on-screen size across zoom levels.
      final pixelRadius = 10.0 + strength * 22.0;
      final radiusMeters = _metersForPixels(
        lat: b.lat,
        zoom: zoom,
        pixels: pixelRadius,
      ).clamp(1.0, 2500000.0);

      circles.add(
        gmaps.Circle(
          circleId: gmaps.CircleId(b.key),
          center: gmaps.LatLng(b.lat, b.lon),
          radius: radiusMeters,
          fillColor: AppColors.accent.withValues(alpha: alpha),
          strokeWidth: 0,
        ),
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: const gmaps.CameraPosition(
        target: gmaps.LatLng(20, 0),
        zoom: 2.4,
      ),
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
      onTap: onTap,
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

class _HeatmapWindowControl extends StatelessWidget {
  const _HeatmapWindowControl({
    required this.value,
    required this.onChanged,
  });

  final HeatmapWindow value;
  final ValueChanged<HeatmapWindow> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.midnightRaised,
      ),
      child: CupertinoSlidingSegmentedControl<HeatmapWindow>(
        groupValue: value,
        thumbColor: AppColors.accent.withValues(alpha: 0.24),
        backgroundColor: CupertinoColors.transparent,
        children: const {
          HeatmapWindow.today: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Today'),
          ),
          HeatmapWindow.days7: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('7 Days'),
          ),
          HeatmapWindow.days30: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('30 Days'),
          ),
          HeatmapWindow.allTime: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('All Time'),
          ),
        },
        onValueChanged: (v) {
          if (v == null) return;
          onChanged(v);
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

class _Legend extends StatelessWidget {
  const _Legend({required this.maxCount});

  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (maxCount <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        const Text(
          'Low',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Row(
              children: List.generate(14, (i) {
                final t = i / 13.0;
                final a = (0.06 + t * 0.42).clamp(0.06, 0.55);
                return Expanded(
                  child: Container(
                    height: 6,
                    color: AppColors.accent.withValues(alpha: a),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'High',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
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

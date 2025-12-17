import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';

class ThundraMap extends StatelessWidget {
  const ThundraMap({
    required this.mapController,
    required this.layers,
    super.key,
    this.initialCenter = const LatLng(20, 0),
    this.initialZoom = 2.4,
    this.onTap,
  });

  final MapController mapController;
  final List<Widget> layers;
  final LatLng initialCenter;
  final double initialZoom;
  final TapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const isFlutterTestConst = bool.fromEnvironment('FLUTTER_TEST');
    final isFlutterTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
    final isFlutterTest = isFlutterTestConst || isFlutterTestEnv;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        backgroundColor: AppColors.midnight,
        onTap: onTap,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        if (!isFlutterTest)
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.thundra.thundra',
            retinaMode: true,
            tileProvider: NetworkTileProvider(),
          ),
        ...layers,
        if (!isFlutterTest)
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '© OpenStreetMap',
                textStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                onTap: () {},
              ),
              TextSourceAttribution(
                '© CARTO',
                textStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                onTap: () {},
              ),
            ],
          ),
      ],
    );
  }
}

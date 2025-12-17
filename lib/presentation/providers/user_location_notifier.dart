import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/datasources/lightning_datasource.dart';
import 'app_providers.dart';

final userLocationProvider =
    AsyncNotifierProvider<UserLocationNotifier, Position?>(
  UserLocationNotifier.new,
);

class UserLocationNotifier extends AsyncNotifier<Position?> {
  @override
  Future<Position?> build() async {
    return null;
  }

  Future<void> warmup() async {
    // Avoid eager permission prompts; check availability only.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) return;
  }

  Future<Position?> requestAndFetch() async {
    state = const AsyncValue.loading();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = const AsyncValue.data(null);
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = const AsyncValue.data(null);
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    state = AsyncValue.data(position);

    // Improve developer testing: steer mock strikes near the user sometimes.
    final ds = ref.read(lightningDataSourceProvider);
    if (ds is FocusableLightningDataSource) {
      ds.setFocus(lat: position.latitude, lon: position.longitude);
    }
    return position;
  }
}

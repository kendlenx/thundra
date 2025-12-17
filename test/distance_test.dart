import 'package:flutter_test/flutter_test.dart';

import 'package:thundra/domain/services/distance.dart';

void main() {
  test('haversineKm ~111.19km for 1 degree longitude at equator', () {
    final km = haversineKm(lat1: 0, lon1: 0, lat2: 0, lon2: 1);
    expect(km, closeTo(111.19, 0.6));
  });

  test('haversineKm is symmetric', () {
    final a = haversineKm(lat1: 37.7749, lon1: -122.4194, lat2: 51.5074, lon2: -0.1278);
    final b = haversineKm(lat1: 51.5074, lon1: -0.1278, lat2: 37.7749, lon2: -122.4194);
    expect(a, closeTo(b, 0.001));
  });
}


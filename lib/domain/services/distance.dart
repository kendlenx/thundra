import 'dart:math' as math;

double haversineKm({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a = _sin2(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          _sin2(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * math.pi / 180.0;
double _sin2(double x) => math.sin(x) * math.sin(x);


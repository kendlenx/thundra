class HeatBin {
  const HeatBin({
    required this.lat,
    required this.lon,
    required this.count,
    required this.latBin,
    required this.lonBin,
  });

  /// Bin center (recommended for visualization).
  final double lat;
  final double lon;

  /// Deterministic bin start coordinates.
  final double latBin;
  final double lonBin;

  final int count;

  String get key => '$latBin,$lonBin';
}


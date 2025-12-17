enum StrikeSource {
  mock,
  realtime,
  imported,
}

class Strike {
  const Strike({
    required this.id,
    required this.lat,
    required this.lon,
    required this.timestamp,
    this.intensity,
    this.source = StrikeSource.mock,
  });

  final String id;
  final double lat;
  final double lon;
  final DateTime timestamp;

  // Optional fields used by other parts of the app; Live Map can ignore.
  final double? intensity;
  final StrikeSource source;

  @override
  bool operator ==(Object other) {
    return other is Strike &&
        other.id == id &&
        other.lat == lat &&
        other.lon == lon &&
        other.timestamp == timestamp &&
        other.intensity == intensity &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(id, lat, lon, timestamp, intensity, source);
}


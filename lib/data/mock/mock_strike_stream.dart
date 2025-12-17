import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/models/strike.dart';

class MockStrikeStream {
  MockStrikeStream({
    this.seed,
    this.minInterval = const Duration(seconds: 1),
    this.maxInterval = const Duration(seconds: 3),
    this.retention = const Duration(minutes: 60),
    this.nearFocusProbability = 0.35,
    this.nearFocusMaxDeltaDegrees = 0.18,
  });

  final int? seed;
  final Duration minInterval;
  final Duration maxInterval;
  final Duration retention;
  final double nearFocusProbability;
  final double nearFocusMaxDeltaDegrees;

  final _controller = StreamController<List<Strike>>.broadcast();
  final _events = StreamController<Strike>.broadcast();
  final _uuid = const Uuid();
  late final Random _rng = Random(seed);

  final List<Strike> _buffer = [];
  Timer? _timer;
  bool _running = false;

  double? _focusLat;
  double? _focusLon;

  Stream<List<Strike>> get stream => _controller.stream;
  Stream<Strike> get events => _events.stream;

  void setFocus({required double lat, required double lon}) {
    _focusLat = lat.clamp(-90.0, 90.0);
    _focusLon = lon.clamp(-180.0, 180.0);
  }

  void start() {
    if (_running) return;
    _running = true;
    _scheduleNext();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
    await _events.close();
  }

  void _scheduleNext() {
    if (!_running) return;
    final minMs = minInterval.inMilliseconds;
    final maxMs = maxInterval.inMilliseconds;
    final delayMs = minMs + _rng.nextInt(max(1, maxMs - minMs + 1));

    _timer = Timer(Duration(milliseconds: delayMs), () {
      _emitNext();
      _scheduleNext();
    });
  }

  void _emitNext() {
    final now = DateTime.now().toUtc();

    final (lat, lon) = _nextLatLon();
    final strike = Strike(
      id: _uuid.v7(),
      lat: lat,
      lon: lon,
      timestamp: now,
    );

    _buffer.add(strike);

    final cutoff = now.subtract(retention);
    _buffer.removeWhere((s) => s.timestamp.isBefore(cutoff));

    _controller.add(List.unmodifiable(_buffer));
    _events.add(strike);
  }

  (double lat, double lon) _nextLatLon() {
    final focusLat = _focusLat;
    final focusLon = _focusLon;
    if (focusLat != null &&
        focusLon != null &&
        _rng.nextDouble() < nearFocusProbability) {
      final lat = (focusLat + _jitter(maxDelta: nearFocusMaxDeltaDegrees))
          .clamp(-90.0, 90.0);
      final lon = (focusLon + _jitter(maxDelta: nearFocusMaxDeltaDegrees))
          .clamp(-180.0, 180.0);
      return (lat, lon);
    }

    final lat = _rng.nextDouble() * 180 - 90;
    final lon = _rng.nextDouble() * 360 - 180;
    return (lat, lon);
  }

  double _jitter({required double maxDelta}) {
    return (_rng.nextDouble() * 2 - 1) * maxDelta;
  }
}

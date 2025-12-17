import '../../domain/models/strike.dart';
import '../mock/mock_strike_stream.dart';
import 'lightning_datasource.dart';

class MockLightningDataSource implements FocusableLightningDataSource {
  MockLightningDataSource({
    int? seed,
  }) : _stream = MockStrikeStream(seed: seed);

  final MockStrikeStream _stream;

  @override
  Stream<Strike> strikesStream() => _stream.events;

  @override
  Future<void> start() async {
    _stream.start();
  }

  @override
  Future<void> stop() async {
    _stream.stop();
  }

  @override
  void setFocus({required double lat, required double lon}) {
    _stream.setFocus(lat: lat, lon: lon);
  }
}


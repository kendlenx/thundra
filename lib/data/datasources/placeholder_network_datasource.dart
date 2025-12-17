import '../../domain/models/strike.dart';
import 'lightning_datasource.dart';

/// Non-functional placeholder (structure only).
/// TODO: Implement a real-time feed (WebSocket/SSE/HTTP polling) with a free source.
class PlaceholderNetworkDataSource implements LightningDataSource {
  const PlaceholderNetworkDataSource();

  @override
  Stream<Strike> strikesStream() => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}


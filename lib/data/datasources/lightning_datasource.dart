import '../../domain/models/strike.dart';

abstract interface class LightningDataSource {
  Stream<Strike> strikesStream();

  /// Optional lifecycle hooks for sources that need timers/sockets.
  Future<void> start();
  Future<void> stop();
}

abstract interface class FocusableLightningDataSource implements LightningDataSource {
  void setFocus({required double lat, required double lon});
}


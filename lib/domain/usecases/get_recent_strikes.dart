import '../models/strike.dart';
import '../repositories/strike_repository.dart';

class GetRecentStrikes {
  const GetRecentStrikes(this._repository);

  final StrikeRepository _repository;

  Stream<List<Strike>> watch({required Duration window}) {
    return _repository.watchRecent(window: window);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/strike.dart';
import '../providers/app_providers.dart';

final liveWindowMinutesProvider = StateProvider<int>((ref) => 5);

final liveStrikesProvider = StreamProvider<List<Strike>>((ref) {
  final windowMinutes = ref.watch(liveWindowMinutesProvider);
  final window = Duration(minutes: windowMinutes);

  return ref.watch(strikeRepositoryProvider).watchRecent(window: window);
});

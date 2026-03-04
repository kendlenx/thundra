import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

final onboardingProvider = AsyncNotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends AsyncNotifier<bool> {
  static const _key = 'onboarding_complete';

  @override
  Future<bool> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final complete = prefs.getBool(_key) ?? false;
    if (!complete) {
      final growth = await ref.read(growthServiceProvider.future);
      await growth.trackEvent('onboarding_presented');
    }
    return complete;
  }

  Future<void> complete({
    required String source,
    required bool locationGranted,
    required bool notificationsGranted,
  }) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_key, true);

    final growth = await ref.read(growthServiceProvider.future);
    await growth.trackOnboardingCompleted(
      source: source,
      locationGranted: locationGranted,
      notificationsGranted: notificationsGranted,
    );

    state = const AsyncValue.data(true);
  }
}

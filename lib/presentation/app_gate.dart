import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import 'app_shell.dart';
import 'onboarding/onboarding_controller.dart';
import 'onboarding/onboarding_screen.dart';
import 'providers/app_providers.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appStartupProvider);
    ref.watch(strikeRetentionProvider);
    ref.watch(growthStartupProvider);

    final onboarding = ref.watch(onboardingProvider);
    return onboarding.when(
      loading: () => const CupertinoPageScaffold(
        backgroundColor: AppColors.midnight,
        child: Center(child: CupertinoActivityIndicator(radius: 12)),
      ),
      error: (error, stackTrace) => const AppShell(),
      data: (complete) => complete ? const AppShell() : const OnboardingScreen(),
    );
  }
}

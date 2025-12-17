import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';

class ThundraCard extends StatelessWidget {
  const ThundraCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.separator),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}


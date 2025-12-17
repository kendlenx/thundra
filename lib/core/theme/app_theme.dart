import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

sealed class AppTheme {
  static const cupertinoDark = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.midnight,
    barBackgroundColor: AppColors.midnightRaised,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.textPrimary,
      textStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.2,
      ),
      navTitleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData materialDark(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.midnight,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.midnightRaised,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.separator,
    );
  }
}


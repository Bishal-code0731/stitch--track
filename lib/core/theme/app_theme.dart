import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Builds the StitchTrack [ThemeData].
abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.navy,
      onPrimary: AppColors.surface,
      secondary: AppColors.amber,
      onSecondary: AppColors.ink,
      error: Color(0xFFDC2626),
      onError: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.hairline,
      textTheme: AppTypography.textTheme(AppColors.ink),
    );
  }
}

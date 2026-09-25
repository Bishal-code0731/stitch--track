import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static const List<FontFeature> _tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(Color color) {
    TextStyle mukta(
      double size,
      FontWeight weight, {
      double? letterSpacing,
      List<FontFeature>? fontFeatures,
    }) {
      return GoogleFonts.mukta(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: fontFeatures,
      );
    }

    return TextTheme(
      // Big numbers / amounts — weight 800, tabular figures.
      displayLarge: mukta(34, FontWeight.w800, fontFeatures: _tabularFigures),
      displayMedium: mukta(28, FontWeight.w800, fontFeatures: _tabularFigures),
      displaySmall: mukta(22, FontWeight.w800, fontFeatures: _tabularFigures),
      // Screen titles.
      titleLarge: mukta(20, FontWeight.w700),
      titleMedium: mukta(18, FontWeight.w700),
      // Section labels (widgets apply .toUpperCase() where needed).
      labelLarge: mukta(13, FontWeight.w700, letterSpacing: 0.5),
      labelMedium: mukta(12.5, FontWeight.w700, letterSpacing: 0.5),
      // Body.
      bodyLarge: mukta(16, FontWeight.w500),
      bodyMedium: mukta(14, FontWeight.w500),
      // Caption.
      bodySmall: mukta(12, FontWeight.w600),
      labelSmall: mukta(11.5, FontWeight.w600),
    );
  }
}

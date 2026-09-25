import 'package:flutter/widgets.dart';

/// StitchTrack color tokens.
abstract final class AppColors {
  // Brand / neutrals
  /// Primary / Navy — app bars, primary buttons, headings, brand.
  static const Color navy = Color(0xFF1F3864);

  /// Navy dark — gradients, pressed states.
  static const Color navyDark = Color(0xFF16294A);

  /// Accent / Amber — FAB, key CTAs, highlights, active step.
  static const Color amber = Color(0xFFE0A800);

  /// Amber dark — amber text/icons on light backgrounds (contrast).
  static const Color amberDark = Color(0xFFB98700);

  /// Ink — primary text.
  static const Color ink = Color(0xFF1B2330);

  /// Muted text — secondary text.
  static const Color mutedText = Color(0xFF5B6472);

  /// Faint text — captions, labels, placeholders.
  static const Color faintText = Color(0xFF8A93A2);

  /// Hairline — borders, dividers.
  static const Color hairline = Color(0xFFE5E8EE);

  /// App background — screen background.
  static const Color background = Color(0xFFF3F5F9);

  /// Surface — cards, sheets, inputs.
  static const Color surface = Color(0xFFFFFFFF);
}

/// A status color triplet: the primary color plus its chip background and chip text colors.
@immutable
class StatusColor {
  const StatusColor({
    required this.color,
    required this.chipBackground,
    required this.chipText,
  });

  final Color color;
  final Color chipBackground;
  final Color chipText;
}

/// Order/garment state colors, exact from `docs/03-design-system.md`.
abstract final class StatusColors {
  static const StatusColor cutting = StatusColor(
    color: Color(0xFF2563EB),
    chipBackground: Color(0xFFE4EDFC),
    chipText: Color(0xFF1D4FB0),
  );

  static const StatusColor stitching = StatusColor(
    color: Color(0xFF5B47C7),
    chipBackground: Color(0xFFECE9FB),
    chipText: Color(0xFF4B36A8),
  );

  /// Trial / Delayed.
  static const StatusColor trial = StatusColor(
    color: Color(0xFFE0A800),
    chipBackground: Color(0xFFFFF4DC),
    chipText: Color(0xFFB98700),
  );

  static const StatusColor ready = StatusColor(
    color: Color(0xFF16A34A),
    chipBackground: Color(0xFFE2F4E9),
    chipText: Color(0xFF15803D),
  );

  static const StatusColor delivered = StatusColor(
    color: Color(0xFF9AA3B0),
    chipBackground: Color(0xFFEDEFF2),
    chipText: Color(0xFF6B7280),
  );

  /// Overdue / Error.
  static const StatusColor overdue = StatusColor(
    color: Color(0xFFDC2626),
    chipBackground: Color(0xFFFBE9E7),
    chipText: Color(0xFFDC2626),
  );

  /// WhatsApp channel indicator.
  static const StatusColor whatsapp = StatusColor(
    color: Color(0xFF1FA855),
    chipBackground: Color(0xFFEAF7EF),
    chipText: Color(0xFF1FA855),
  );
}

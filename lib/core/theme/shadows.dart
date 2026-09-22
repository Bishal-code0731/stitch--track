import 'package:flutter/widgets.dart';

/// StitchTrack shadow presets.
abstract final class AppShadows {
  /// Card: `0 1px 2px rgba(20,40,80,0.05)`.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(20, 40, 80, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(31, 56, 100, 0.24),
      offset: Offset(0, 7),
      blurRadius: 18,
    ),
  ];

  /// Sheet: `0 10px 30px rgba(0,0,0,0.28)`.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.28),
      offset: Offset(0, 10),
      blurRadius: 30,
    ),
  ];
}

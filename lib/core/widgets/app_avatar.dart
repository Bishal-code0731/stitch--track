import 'package:flutter/material.dart';

/// Circular initials avatar.
class AppAvatar extends StatelessWidget {
  const AppAvatar({required this.name, this.seed, this.size = 40, super.key});

  final String name;

  /// Stable identity to hash for the color (e.g.
  final String? seed;
  final double size;

  /// Palette of tinted backgrounds; text is drawn in the paired dark tone.
  static const List<(Color, Color)> _palette = [
    (Color(0xFFE4EDFC), Color(0xFF1D4FB0)),
    (Color(0xFFECE9FB), Color(0xFF4B36A8)),
    (Color(0xFFE2F4E9), Color(0xFF15803D)),
    (Color(0xFFFFF4DC), Color(0xFFB98700)),
    (Color(0xFFFBE9E7), Color(0xFFDC2626)),
    (Color(0xFFEAF7EF), Color(0xFF1FA855)),
  ];

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  static int _hash(String s) {
    var h = 0;
    for (final unit in s.codeUnits) {
      h = (h * 31 + unit) & 0x7fffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _palette[_hash(seed ?? name) % _palette.length];
    // Screen readers announce the full name, not the "BJ" initials.
    return Semantics(
      label: name,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            initialsOf(name),
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/colors.dart';

enum GarmentKind {
  shirt,
  trouser,
  suit,
  coat,
  daura,
  kurta,
  blouse,
  sari,
  lehenga,
  scarf,
  generic,
}

/// Maps a template's English name to a glyph kind by keyword.
GarmentKind garmentGlyphFor(String nameEn) {
  final n = nameEn.toLowerCase();
  if (n.contains('shirt') && !n.contains('t-shirt')) return GarmentKind.shirt;
  if (n.contains('trouser') || n.contains('pant')) return GarmentKind.trouser;
  if (n.contains('suit')) return GarmentKind.suit;
  if (n.contains('coat')) return GarmentKind.coat;
  if (n.contains('daura')) return GarmentKind.daura;
  if (n.contains('kurta')) return GarmentKind.kurta;
  if (n.contains('blouse')) return GarmentKind.blouse;
  if (n.contains('sari') || n.contains('cholo')) return GarmentKind.sari;
  if (n.contains('lehenga')) return GarmentKind.lehenga;
  if (n.contains('shawl') || n.contains('scarf') || n.contains('sal')) {
    return GarmentKind.scarf;
  }
  return GarmentKind.generic;
}

/// Inner SVG markup per kind (the exact `<path>`s from the mockup).
const Map<GarmentKind, String?> _glyphPaths = {
  GarmentKind.shirt:
      '<path d="M8 3l-4 3 1.5 3L7 8v13h10V8l1.5 1L20 6l-4-3-2 2h-4L8 3z" />',
  GarmentKind.trouser:
      '<path d="M7 3h10l-.5 18H14l-2-12-2 12H7.5L7 3z" /><path d="M7 3h10" />',
  GarmentKind.suit:
      '<path d="M8 3l-3 2 1 4v12h12V9l1-4-3-2-1 3h-6L8 3z" /><path d="M12 6v15M9 8l3 4 3-4" stroke-width="1.3" />',
  GarmentKind.coat:
      '<path d="M8 3L4 6l2 3v12h12V9l2-3-4-3-2 2.5h-4L8 3z" /><path d="M12 5.5V21" stroke-width="1.3" />',
  GarmentKind.daura:
      '<path d="M9 3L5 6l1.5 3L8 8v13h8V8l1.5 1L18 6l-4-3-1 2-2 1.5L9 5 9 3z" /><path d="M8 9c2 1 6 1 8 0" stroke-width="1.3" />',
  GarmentKind.kurta:
      '<path d="M9 3L5 6l1.5 3L8 8v13h8V8l1.5 1L18 6l-4-3-1 2h-3L9 3z" /><path d="M12 5v9" stroke-width="1.3" />',
  GarmentKind.blouse:
      '<path d="M8 3L4 6l1.5 3L7 8.2V21h10V8.2L18.5 9 20 6l-4-3-1.5 2.5a3 3 0 01-5 0L8 3z" />',
  GarmentKind.sari:
      '<path d="M4 4c6 2 10 6 16 16M4 9c5 1 8 4 12 11M5 20h14" stroke-width="1.6" />',
  GarmentKind.lehenga:
      '<path d="M9 3h6l1 5 4 13H4l4-13 1-5z" /><path d="M9 8h6" stroke-width="1.3" />',
  GarmentKind.scarf:
      '<path d="M6 3c2 5 2 9 0 18M18 3c-2 5-2 9 0 18M6 3h12" stroke-width="1.6" /><path d="M6 21l3-2M18 21l-3-2" stroke-width="1.4" />',
  GarmentKind.generic: null,
};

class GarmentGlyph extends StatelessWidget {
  const GarmentGlyph({
    required this.kind,
    this.size = 30,
    this.color = AppColors.navy,
    this.strokeWidth = 1.7,
    super.key,
  });

  final GarmentKind kind;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final inner = _glyphPaths[kind];
    if (inner == null) {
      return Icon(Icons.checkroom, size: size, color: color);
    }
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$size" '
        'height="$size" viewBox="0 0 24 24" fill="none" stroke="$hex" '
        'stroke-width="$strokeWidth" stroke-linecap="round" '
        'stroke-linejoin="round">$inner</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

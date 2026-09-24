import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoreGlyph extends StatelessWidget {
  const StoreGlyph({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  static const _svg =
      '<svg viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="1.6" '
      'stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M4 9l1-4h14l1 4M4 9h16M4 9v10h16V9"/></svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

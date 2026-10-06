import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/colors.dart';

class BrandBadge extends StatelessWidget {
  const BrandBadge({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.28),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/branding/logo.svg',
        width: size * 0.58,
        height: size * 0.58,
      ),
    );
  }
}

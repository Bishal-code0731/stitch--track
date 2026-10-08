import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class StepIconBadge extends StatelessWidget {
  const StepIconBadge({required this.icon, this.size = 60, super.key});

  final IconData icon;
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
            color: AppColors.navy.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.amber, size: size * 0.46),
    );
  }
}

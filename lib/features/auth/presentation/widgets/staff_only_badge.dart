import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';

class StaffOnlyBadge extends StatelessWidget {
  const StaffOnlyBadge({this.icon = Icons.lock_outline, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDF3),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.faintText),
          const SizedBox(width: 7),
          Text(
            'auth_staff_only_note'.tr(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

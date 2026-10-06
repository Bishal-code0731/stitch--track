import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class RequirementRow extends StatelessWidget {
  const RequirementRow({required this.met, required this.label, super.key});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? StatusColors.ready.color : AppColors.faintText;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? StatusColors.ready.color : const Color(0xFFE1E5EC),
          ),
          alignment: Alignment.center,
          child: met
              ? const Icon(Icons.check, size: 12, color: AppColors.surface)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

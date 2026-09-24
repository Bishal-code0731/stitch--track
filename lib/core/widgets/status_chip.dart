import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

/// Status pill for order/garment state.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.icon,
    required this.status,
    super.key,
  });

  final String label;
  final IconData icon;
  final StatusColor status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.chipBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: status.chipText),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.chipText,
            ),
          ),
        ],
      ),
    );
  }
}

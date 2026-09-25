import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/shadows.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.orderNumber,
    required this.customerName,
    required this.garmentSummary,
    required this.statusLabel,
    required this.statusIcon,
    required this.status,
    required this.dueLabel,
    this.isOverdue = false,
    this.onTap,
    super.key,
  });

  final String orderNumber;
  final String customerName;
  final String garmentSummary;
  final String statusLabel;
  final IconData statusIcon;
  final StatusColor status;
  final String dueLabel;
  final bool isOverdue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card,
            border: Border(
              left: BorderSide(
                color: isOverdue
                    ? StatusColors.overdue.color
                    : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      orderNumber,
                      style: text.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip(
                    label: statusLabel,
                    icon: statusIcon,
                    status: status,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(customerName, style: text.bodyLarge),
              const SizedBox(height: 2),
              Text(
                garmentSummary,
                style: text.bodySmall?.copyWith(color: AppColors.mutedText),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: isOverdue
                        ? StatusColors.overdue.color
                        : AppColors.faintText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dueLabel,
                    style: text.bodySmall?.copyWith(
                      color: isOverdue
                          ? StatusColors.overdue.color
                          : AppColors.mutedText,
                      fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/numerals.dart';

class OrderWizardStepper extends StatelessWidget {
  const OrderWizardStepper({required this.activeIndex, super.key});

  /// 0-based index of the current step.
  final int activeIndex;

  static const _labelKeys = [
    'neworder_step_customer',
    'neworder_step_garments',
    'neworder_step_measure',
    'neworder_step_review',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final children = <Widget>[];
    for (var i = 0; i < _labelKeys.length; i++) {
      children.add(
        _StepNode(
          index: i,
          activeIndex: activeIndex,
          label: _labelKeys[i].tr(),
          locale: locale,
        ),
      );
      if (i < _labelKeys.length - 1) {
        children.add(
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(top: 13),
              decoration: BoxDecoration(
                color: i < activeIndex
                    ? AppColors.amber
                    : AppColors.surface.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.activeIndex,
    required this.label,
    required this.locale,
  });

  final int index;
  final int activeIndex;
  final String label;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final done = index < activeIndex;
    final on = index == activeIndex;

    final Color bg;
    final Color fg;
    if (on) {
      bg = AppColors.amber;
      fg = AppColors.navyDark;
    } else if (done) {
      bg = AppColors.surface.withValues(alpha: 0.95);
      fg = AppColors.navy;
    } else {
      bg = AppColors.surface.withValues(alpha: 0.14);
      fg = AppColors.surface.withValues(alpha: 0.7);
    }

    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: done
                ? Icon(Icons.check, size: 15, color: fg)
                : Text(
                    numerals(index + 1, locale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: on ? FontWeight.w700 : FontWeight.w600,
              color: on
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

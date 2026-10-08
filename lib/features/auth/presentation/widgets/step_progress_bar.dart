import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Thin N-segment amber progress bar (5px tall, rounded, amber for done/ current vs.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    required this.stepCount,
    required this.currentIndex,
    super.key,
  });

  final int stepCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stepCount; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 5,
              decoration: BoxDecoration(
                color: i <= currentIndex
                    ? AppColors.amber
                    : const Color(0xFFD7DCE6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

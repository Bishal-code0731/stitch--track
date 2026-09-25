import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({
    required this.labels,
    required this.currentIndex,
    super.key,
  });

  final List<String> labels;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _StepDot(index: i, label: labels[i], currentIndex: currentIndex),
          if (i < labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: i < currentIndex ? AppColors.amber : AppColors.hairline,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.currentIndex,
  });

  final int index;
  final String label;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentIndex;
    final isActive = index == currentIndex;
    final color = isDone || isActive ? AppColors.amber : AppColors.hairline;
    final fg = isDone || isActive ? AppColors.ink : AppColors.faintText;

    final state = isDone
        ? 'completed'
        : isActive
        ? 'current'
        : 'upcoming';
    return Semantics(
      label: '$label, step ${index + 1}, $state',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: AppColors.ink)
                : Text(
                    '${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: fg),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? AppColors.ink : AppColors.faintText,
            ),
          ),
        ],
      ),
    );
  }
}

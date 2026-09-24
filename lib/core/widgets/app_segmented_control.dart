import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

/// One choice in an [AppSegmentedControl].
class AppSegment<T> {
  const AppSegment({required this.value, required this.label});
  final T value;
  final String label;
}

/// Segmented control used for tabs, period toggles, and filter chips (see `docs/03-design-system.md`).
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final segment in segments)
            _Segment(
              label: segment.label,
              selected: segment.value == selected,
              onTap: () => onChanged(segment.value),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: selected ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.surface : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

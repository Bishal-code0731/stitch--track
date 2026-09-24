import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Amber floating action button for create actions (see `docs/03-design-system.md`).
class AppFab extends StatelessWidget {
  const AppFab({
    required this.onPressed,
    required this.tooltip,
    this.icon = Icons.add,
    super.key,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.amber,
      foregroundColor: AppColors.ink,
      child: Icon(icon),
    );
  }
}

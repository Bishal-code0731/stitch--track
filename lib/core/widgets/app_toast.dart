import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

void showAppToast(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      duration: const Duration(seconds: 2),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (success) ...[
            Icon(Icons.check_circle, color: StatusColors.ready.color, size: 18),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    ),
  );
}

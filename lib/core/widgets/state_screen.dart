import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'app_button.dart';

/// Which state a [StateScreen] represents.
enum StateScreenKind { empty, error, offline }

class StateScreen extends StatelessWidget {
  const StateScreen({
    required this.kind,
    this.title,
    this.message,
    this.onRetry,
    super.key,
  });

  const StateScreen.empty({Key? key, String? title, String? message})
    : this(
        kind: StateScreenKind.empty,
        title: title,
        message: message,
        key: key,
      );

  const StateScreen.error({Key? key, VoidCallback? onRetry})
    : this(kind: StateScreenKind.error, onRetry: onRetry, key: key);

  const StateScreen.offline({Key? key, VoidCallback? onRetry})
    : this(kind: StateScreenKind.offline, onRetry: onRetry, key: key);

  final StateScreenKind kind;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  IconData get _icon => switch (kind) {
    StateScreenKind.empty => Icons.inbox_outlined,
    StateScreenKind.error => Icons.error_outline,
    StateScreenKind.offline => Icons.wifi_off_outlined,
  };

  String get _defaultTitleKey => switch (kind) {
    StateScreenKind.empty => 'state_empty_title',
    StateScreenKind.error => 'state_error_title',
    StateScreenKind.offline => 'state_offline_title',
  };

  String get _defaultMessageKey => switch (kind) {
    StateScreenKind.empty => 'state_empty_message',
    StateScreenKind.error => 'state_error_message',
    StateScreenKind.offline => 'state_offline_message',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 56, color: AppColors.faintText),
            const SizedBox(height: 16),
            Text(
              title ?? _defaultTitleKey.tr(),
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? _defaultMessageKey.tr(),
              style: text.bodyMedium?.copyWith(color: AppColors.mutedText),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: 'action_retry'.tr(),
                icon: Icons.refresh,
                expand: false,
                variant: AppButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

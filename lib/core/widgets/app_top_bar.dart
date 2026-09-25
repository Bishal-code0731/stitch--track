import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';
import 'language_toggle.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: showBack ? 0 : 16,
      leadingWidth: showBack ? 56 : 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _BackButton(onBack: onBack),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleLarge?.copyWith(color: AppColors.surface),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: text.bodySmall?.copyWith(
                color: AppColors.surface.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
      actions: [
        ...actions,
        const Padding(
          padding: EdgeInsets.only(right: 12, left: 4),
          child: LanguageToggle(),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.iconTile),
        onTap: onBack ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.iconTile),
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

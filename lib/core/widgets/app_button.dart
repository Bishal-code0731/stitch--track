import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

/// The four button roles from `docs/03-design-system.md`'s component table.
enum AppButtonVariant { primary, secondary, destructive, text }

/// StitchTrack button.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.height,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Whether the button stretches to the available width (default) or hugs its content.
  final bool expand;

  /// Shows a spinner in place of the label and disables interaction — e.g.
  final bool loading;

  /// Overrides the default height (52px).
  final double? height;

  static const double _height = 52; // ≥48px primary-action target.
  static const double _textHeight = 44; // minimum tap target.

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _height;
    final effectiveOnPressed = loading ? null : onPressed;
    final child = _buildChild();
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        style: _filledStyle(AppColors.navy, AppColors.surface, effectiveHeight),
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: effectiveOnPressed,
        style: _filledStyle(
          StatusColors.overdue.color,
          AppColors.surface,
          effectiveHeight,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, effectiveHeight),
          foregroundColor: AppColors.navy,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, _textHeight),
          foregroundColor: AppColors.navy,
        ),
        child: child,
      ),
    };

    final result = loading ? Opacity(opacity: 0.85, child: button) : button;
    return expand ? SizedBox(width: double.infinity, child: result) : result;
  }

  ButtonStyle _filledStyle(Color bg, Color fg, double height) =>
      FilledButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
      );

  Widget _buildChild() {
    if (loading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.surface,
        ),
      );
    }
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}

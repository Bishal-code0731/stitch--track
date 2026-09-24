import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.icon,
    this.placeholder,
    this.hint,
    this.obscureText = false,
    this.canToggleObscure = false,
    this.keyboardType,
    this.textInputAction,
    this.hasError = false,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.height = 54,
    super.key,
  });

  final String label;
  final TextEditingController? controller;

  /// Leading icon shown inside the field, left of the text (e.g.
  final IconData? icon;

  final String? placeholder;

  /// Persistent caption below the field (e.g.
  final String? hint;

  final bool obscureText;

  /// Shows a show/hide eye toggle.
  final bool canToggleObscure;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Turns the border red.
  final bool hasError;

  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final double height;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? StatusColors.overdue.color
        : _focused
        ? AppColors.navy
        : AppColors.hairline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: borderColor,
              width: _focused || widget.hasError ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color.fromRGBO(20, 40, 80, 0.04),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: _focused ? AppColors.navy : AppColors.faintText,
                ),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLength: widget.maxLength,
                  style: const TextStyle(fontSize: 16, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(color: AppColors.faintText),
                    border: InputBorder.none,
                    isDense: true,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.canToggleObscure)
                IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.faintText,
                  ),
                  tooltip: _obscured ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscured = !_obscured),
                ),
            ],
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              widget.hint!,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.faintText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

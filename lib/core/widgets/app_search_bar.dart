import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/radii.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller.addListener(_onChangedInternal);
  }

  void _onChangedInternal() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChangedInternal);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: const Icon(Icons.search, color: AppColors.faintText),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).modalBarrierDismissLabel,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                  },
                )
              : null,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.input),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
        ),
      ),
    );
  }
}

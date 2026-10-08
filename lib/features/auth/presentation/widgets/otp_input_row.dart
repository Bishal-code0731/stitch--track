import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({required this.value, required this.onChanged, super.key});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  static const _digitCount = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final padded = widget.value.padRight(_digitCount);
    _controllers = [
      for (var i = 0; i < _digitCount; i++)
        TextEditingController(text: padded[i].trim()),
    ];
    _focusNodes = List.generate(
      _digitCount,
      (i) => FocusNode()
        ..onKeyEvent = (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[i].text.isEmpty &&
              i > 0) {
            _controllers[i - 1].clear();
            _focusNodes[i - 1].requestFocus();
            _emit();
            setState(() {});
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  void _onChanged(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    final digit = digitsOnly.isEmpty
        ? null
        : digitsOnly.substring(digitsOnly.length - 1);
    _controllers[index].text = digit ?? '';
    if (digit != null && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _digitCount; i++)
          SizedBox(
            width: 46,
            height: 58,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _controllers[i].text.isNotEmpty
                    ? const Color(0xFFEEF2FA)
                    : AppColors.surface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  borderSide: BorderSide(
                    color: _controllers[i].text.isNotEmpty
                        ? AppColors.navy
                        : AppColors.hairline,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  borderSide: BorderSide(
                    color: _controllers[i].text.isNotEmpty
                        ? AppColors.navy
                        : AppColors.hairline,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) => setState(() => _onChanged(i, v)),
            ),
          ),
      ],
    );
  }
}

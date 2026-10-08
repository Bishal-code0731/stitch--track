import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/widgets/app_button.dart';

class TwoFactorEnabledScreen extends StatelessWidget {
  const TwoFactorEnabledScreen({super.key});

  static const _backupCodes = [
    '4F2A-9C',
    '7B1E-X3',
    'K0P5-2D',
    'M8Q4-7A',
    '3R6T-1L',
    'Z9N2-8B',
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final green = StatusColors.ready.color;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StatusColors.ready.chipBackground,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 44,
                        color: green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'auth_2fa_enabled_title'.tr(),
                      textAlign: TextAlign.center,
                      style: text.displaySmall?.copyWith(fontSize: 25),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 300,
                      child: Text(
                        'auth_2fa_enabled_message'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _BackupCodesCard(codes: _backupCodes),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: AppButton(
                label: 'auth_2fa_done'.tr(),
                height: 56,
                onPressed: () => context.canPop() ? context.pop() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupCodesCard extends StatelessWidget {
  const _BackupCodesCard({required this.codes});
  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'auth_2fa_backup_codes'.tr().toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.faintText,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < codes.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _CodeChip(code: codes[i])),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < codes.length
                      ? _CodeChip(code: codes[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

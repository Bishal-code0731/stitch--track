import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../widgets/step_icon_badge.dart';

enum _TwoFactorMethod { authenticator, email }

class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() =>
      _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  _TwoFactorMethod _method = _TwoFactorMethod.authenticator;

  void _leave() {
    if (context.canPop()) context.pop();
  }

  void _continue() {
    context.push(
      Routes.twoFactorVerify(
        _method == _TwoFactorMethod.authenticator ? 'authenticator' : 'email',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextButton.icon(
                      onPressed: _leave,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: Text(
                        'auth_2fa_setup_back'.tr(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LanguageToggle(light: true, fullNepaliLabel: true),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StepIconBadge(icon: Icons.shield_outlined),
                    const SizedBox(height: 16),
                    Text(
                      'auth_2fa_setup_title'.tr(),
                      style: text.displaySmall?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'auth_2fa_setup_subtitle'.tr(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'auth_2fa_setup_choose_method'.tr().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.faintText,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MethodCard(
                      icon: Icons.smartphone,
                      title: 'auth_2fa_method_authenticator'.tr(),
                      subtitle: 'auth_2fa_method_authenticator_sub'.tr(),
                      selected: _method == _TwoFactorMethod.authenticator,
                      onTap: () => setState(
                        () => _method = _TwoFactorMethod.authenticator,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MethodCard(
                      icon: Icons.mail_outline,
                      title: 'auth_2fa_method_email'.tr(),
                      subtitle: 'auth_2fa_method_email_sub'.tr(),
                      selected: _method == _TwoFactorMethod.email,
                      onTap: () =>
                          setState(() => _method = _TwoFactorMethod.email),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'auth_2fa_setup_continue'.tr(),
                      height: 56,
                      onPressed: _continue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFBFCFE) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.navy : const Color(0xFFEEF1F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.surface : AppColors.navy,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              selected
                  ? const Icon(Icons.check, size: 22, color: AppColors.navy)
                  : const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: Color(0xFFC7CEDA),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

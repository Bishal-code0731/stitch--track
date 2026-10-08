import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/services/barcode_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../providers/auth_providers.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/step_icon_badge.dart';

/// Second step of 2FA setup (after [TwoFactorSetupScreen]): confirm the second factor, then enable.
class TwoFactorVerifyScreen extends ConsumerStatefulWidget {
  const TwoFactorVerifyScreen({required this.isAuthenticator, super.key});

  final bool isAuthenticator;

  @override
  ConsumerState<TwoFactorVerifyScreen> createState() =>
      _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends ConsumerState<TwoFactorVerifyScreen> {
  /// Demo provisioning secret — real per-user TOTP secrets arrive in Phase 09.
  static const _setupKey = 'K7X4 9B2M QP10';

  String _code = '';
  bool _saving = false;

  String _maskedEmail() {
    final user = ref.read(authSessionProvider).value;
    final local = user?.username ?? 'user';
    final masked = local.length <= 2
        ? local
        : '${local[0]}****${local[local.length - 1]}';
    return '$masked@shop.com';
  }

  Future<void> _verify() async {
    setState(() => _saving = true);
    final user = ref.read(authSessionProvider).value;
    if (user != null) {
      await ref.read(authRepositoryProvider).setTwoFactorEnabled(user.id, true);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    context.pushReplacement(Routes.twoFactorEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authSessionProvider).value;

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
                  IconButton(
                    onPressed: () => context.canPop() ? context.pop() : null,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    color: AppColors.navy,
                  ),
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
                    if (widget.isAuthenticator)
                      _AuthenticatorBlock(
                        setupKey: _setupKey,
                        username: user?.username ?? 'user',
                      )
                    else
                      _EmailBlock(email: _maskedEmail()),
                    const SizedBox(height: 22),
                    Text(
                      'auth_2fa_verify_enter_code'.tr(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OtpInputRow(
                      value: _code,
                      onChanged: (v) => setState(() => _code = v),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'auth_2fa_verify_button'.tr(),
                      height: 56,
                      loading: _saving,
                      onPressed: _code.length == 6 ? _verify : null,
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

class _AuthenticatorBlock extends ConsumerWidget {
  const _AuthenticatorBlock({required this.setupKey, required this.username});
  final String setupKey;
  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrData =
        'otpauth://totp/StitchTrack:$username?secret=${setupKey.replaceAll(' ', '')}&issuer=StitchTrack';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'auth_2fa_verify_scan_qr'.tr(),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.hairline),
            ),
            child: ref.read(barcodeServiceProvider).buildQr(qrData, size: 168),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'auth_2fa_verify_or_key'.tr(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.faintText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Text(
              setupKey,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Email-OTP variant: a full-width "code sent to (masked email)" pill.
class _EmailBlock extends StatelessWidget {
  const _EmailBlock({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FA),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: const Color(0xFFDCE4F2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline, size: 19, color: AppColors.navy),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'auth_2fa_verify_email_sent'.tr(namedArgs: {'email': email}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF34507E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

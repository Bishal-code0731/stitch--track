import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/utils/resend_countdown.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../data/local/local_auth_repository.dart';
import '../../domain/auth_exceptions.dart';
import '../providers/auth_providers.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/requirement_row.dart';
import '../widgets/step_icon_badge.dart';
import '../widgets/step_progress_bar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  static const _resendCooldown = Duration(seconds: 38);

  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _otp = '';

  int _step = 0; // 0 phone, 1 otp, 2 new password, 3 success
  bool _submitting = false;
  String? _errorText;
  DateTime? _lastSentAt;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_resendSecondsRemaining() == 0) _ticker?.cancel();
    });
  }

  int _resendSecondsRemaining() {
    final sentAt = _lastSentAt;
    if (sentAt == null) return 0;
    return resendSecondsRemaining(
      sentAt: sentAt,
      cooldown: _resendCooldown,
      now: DateTime.now(),
    );
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorText = 'Enter your phone number.');
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await ref.read(authRepositoryProvider).requestPasswordResetOtp(phone);
      if (!mounted) return;
      setState(() {
        _step = 1;
        _lastSentAt = DateTime.now();
      });
      _startResendTicker();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: _phoneController.text.trim(), otp: _otp);
      if (!mounted) return;
      setState(() => _step = 2);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            phone: _phoneController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      setState(() => _step = 3);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  if (_step == 0)
                    TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: Text('auth_back_to_login'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                      ),
                    )
                  else if (_step < 3)
                    IconButton(
                      onPressed: () => setState(() => _step -= 1),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      color: AppColors.navy,
                    )
                  else
                    const SizedBox.shrink(),
                  const LanguageToggle(light: true),
                ],
              ),
            ),
            if (_step < 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'auth_forgot_step_label'.tr()} ${_step + 1} '
                      '${'auth_forgot_of_label'.tr()} 3',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.faintText,
                      ),
                    ),
                    const SizedBox(height: 7),
                    StepProgressBar(stepCount: 3, currentIndex: _step),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, AppSpacing.x16),
                child: _buildStep(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final text = Theme.of(context).textTheme;
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIconBadge(icon: Icons.phone_outlined),
            const SizedBox(height: 16),
            Text(
              'auth_forgot_step1_title'.tr(),
              style: text.displaySmall?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 5),
            Text(
              'auth_forgot_step1_sub'.tr(),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'auth_forgot_phone_label'.tr(),
              controller: _phoneController,
              icon: Icons.phone_outlined,
              placeholder: 'auth_phone_placeholder'.tr(),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendCode(),
            ),
            if (_errorText != null) _errorBanner(),
            const SizedBox(height: AppSpacing.x16),
            AppButton(
              label: 'auth_forgot_send_code'.tr(),
              height: 56,
              loading: _submitting,
              onPressed: _sendCode,
            ),
          ],
        );
      case 1:
        final repo = ref.read(authRepositoryProvider);
        final devCode = kDebugMode && repo is LocalAuthRepository
            ? repo.debugLastOtpFor(_phoneController.text.trim())
            : null;
        final remaining = _resendSecondsRemaining();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIconBadge(icon: Icons.shield_outlined),
            const SizedBox(height: 16),
            Text(
              'auth_forgot_step2_title'.tr(),
              style: text.displaySmall?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                  height: 1.45,
                ),
                children: [
                  TextSpan(text: '${'auth_forgot_step2_sub_prefix'.tr()} '),
                  TextSpan(
                    text: '+977 ${_phoneController.text.trim()}',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (devCode != null) ...[
              const SizedBox(height: 8),
              Text(
                'auth_forgot_otp_dev_code'.tr(namedArgs: {'code': devCode}),
                style: const TextStyle(
                  color: AppColors.amberDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 22),
            OtpInputRow(
              value: _otp,
              onChanged: (v) => setState(() => _otp = v),
            ),
            const SizedBox(height: 20),
            _ResendRow(remaining: remaining, onResend: _sendCode),
            if (_errorText != null) _errorBanner(),
            const SizedBox(height: AppSpacing.x16),
            AppButton(
              label: 'auth_verify'.tr(),
              height: 56,
              loading: _submitting,
              onPressed: _otp.length == 6 ? _verifyCode : null,
            ),
          ],
        );
      case 2:
        final lenOk = _newPasswordController.text.length >= 6;
        final matchOk =
            _newPasswordController.text.isNotEmpty &&
            _newPasswordController.text == _confirmPasswordController.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIconBadge(icon: Icons.lock_outline),
            const SizedBox(height: 16),
            Text(
              'auth_forgot_step3_title'.tr(),
              style: text.displaySmall?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 5),
            Text(
              'auth_forgot_step3_sub'.tr(),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'auth_forgot_new_password_label'.tr(),
              controller: _newPasswordController,
              icon: Icons.lock_outline,
              placeholder: '••••••',
              obscureText: true,
              canToggleObscure: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.x14),
            AppTextField(
              label: 'auth_forgot_confirm_password_label'.tr(),
              controller: _confirmPasswordController,
              icon: Icons.lock_outline,
              placeholder: '••••••',
              obscureText: true,
              canToggleObscure: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => (lenOk && matchOk) ? _resetPassword() : null,
            ),
            const SizedBox(height: AppSpacing.x12),
            RequirementRow(
              met: lenOk,
              label: 'auth_min_password_length_hint'.tr(),
            ),
            const SizedBox(height: 8),
            RequirementRow(
              met: matchOk,
              label: 'auth_passwords_match_hint'.tr(),
            ),
            if (_errorText != null) _errorBanner(),
            const SizedBox(height: AppSpacing.x16),
            AppButton(
              label: 'auth_forgot_save_password'.tr(),
              height: 56,
              loading: _submitting,
              onPressed: (lenOk && matchOk) ? _resetPassword : null,
            ),
          ],
        );
      default:
        return const _ForgotPasswordSuccessView();
    }
  }

  Widget _errorBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x8),
      child: Text(
        _errorText!,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: StatusColors.overdue.color,
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.remaining, required this.onResend});

  final int remaining;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: remaining > 0
          ? Text(
              '${'auth_forgot_resend_in_prefix'.tr()} $remaining${'auth_forgot_sec_suffix'.tr()}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            )
          : TextButton(
              onPressed: onResend,
              child: Text('auth_forgot_resend'.tr()),
            ),
    );
  }
}

class _ForgotPasswordSuccessView extends StatelessWidget {
  const _ForgotPasswordSuccessView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFE2F4E9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 48, color: StatusColors.ready.color),
        ),
        const SizedBox(height: AppSpacing.x24),
        Text(
          'auth_forgot_success_title'.tr(),
          style: text.displaySmall?.copyWith(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x8),
        SizedBox(
          width: 280,
          child: Text(
            'auth_forgot_success_message'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedText,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.x24),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'auth_go_to_login'.tr(),
            height: 56,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

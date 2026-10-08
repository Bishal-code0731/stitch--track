import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../domain/auth_exceptions.dart';
import '../../domain/entities/auth_login_result.dart';
import '../providers/auth_providers.dart';
import '../widgets/brand_badge.dart';
import '../widgets/staff_only_badge.dart';

/// Login — phone/username + password.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _showValidationError = false;
  String? _serverError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _showValidationError = true;
        _serverError = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _showValidationError = false;
      _serverError = null;
    });

    try {
      final result = await ref
          .read(authSessionProvider.notifier)
          .login(identifier: identifier, password: password);
      if (!mounted) return;

      switch (result) {
        case AuthLoginSuccess():
          context.go(Routes.welcome);
        case AuthLoginTwoFactorRequired(:final userId):
          unawaited(context.push(Routes.twoFactor(userId)));
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasError =
        _showValidationError &&
        (_identifierController.text.trim().isEmpty ||
            _passwordController.text.isEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: LanguageToggle(light: true),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        const BrandBadge(size: 72),
                        const SizedBox(height: 14),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Stitch',
                                style: TextStyle(color: AppColors.navy),
                              ),
                              TextSpan(
                                text: 'Track',
                                style: TextStyle(color: AppColors.amber),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'auth_login_welcome'.tr(),
                          style: text.displaySmall?.copyWith(fontSize: 25),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'auth_login_manage_shop'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        AppTextField(
                          label: 'auth_identifier_label'.tr(),
                          controller: _identifierController,
                          icon: Icons.person_outline,
                          placeholder: 'auth_identifier_placeholder'.tr(),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          hasError: hasError,
                        ),
                        const SizedBox(height: AppSpacing.x16),
                        AppTextField(
                          label: 'auth_password_label'.tr(),
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          placeholder: 'auth_password_placeholder'.tr(),
                          obscureText: true,
                          canToggleObscure: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          hasError: hasError,
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: AppSpacing.x16),
                        if (_showValidationError || _serverError != null) ...[
                          Text(
                            _serverError ?? 'auth_login_need_both'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: StatusColors.overdue.color,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x16),
                        ],
                        AppButton(
                          label: 'auth_login_button'.tr(),
                          height: 56,
                          loading: _submitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.x8),
                        TextButton(
                          onPressed: () => context.push(Routes.forgotPassword),
                          child: Text('auth_forgot_password'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: StaffOnlyBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

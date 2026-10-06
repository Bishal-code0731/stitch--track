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
import '../providers/auth_providers.dart';
import '../widgets/brand_badge.dart';
import '../widgets/staff_only_badge.dart';

/// Step 3 — staff sign-up gated by a shop invite code.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _inviteCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  bool _submitted = false;
  String? _errorText;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final inviteCode = _inviteCodeController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if ([inviteCode, name, phone, username, password].any((v) => v.isEmpty)) {
      setState(() => _errorText = 'Fill in every field to continue.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            inviteCode: inviteCode,
            name: name,
            phone: phone,
            username: username,
            password: password,
          );
      if (!mounted) return;
      setState(() => _submitted = true);
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
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StaffOnlyBadge(icon: Icons.info_outline),
                  LanguageToggle(light: true),
                ],
              ),
            ),
            Expanded(
              child: _submitted
                  ? const _RegisterSuccessView()
                  : _buildForm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandBadge(size: 58),
          const SizedBox(height: 16),
          Text(
            'auth_register_welcome'.tr(),
            style: text.displaySmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'auth_register_sub'.tr(),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: AppColors.mutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'auth_invite_code_label'.tr(),
            controller: _inviteCodeController,
            icon: Icons.confirmation_number_outlined,
            placeholder: 'auth_invite_code_hint'.tr(),
            hint: 'auth_invite_code_hint'.tr(),
            height: 50,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.x14),
          AppTextField(
            label: 'auth_name_label'.tr(),
            controller: _nameController,
            icon: Icons.person_outline,
            placeholder: 'auth_name_placeholder'.tr(),
            height: 50,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.x14),
          AppTextField(
            label: 'auth_phone_label'.tr(),
            controller: _phoneController,
            icon: Icons.phone_outlined,
            placeholder: 'auth_phone_placeholder'.tr(),
            keyboardType: TextInputType.phone,
            height: 50,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.x14),
          AppTextField(
            label: 'auth_username_label'.tr(),
            controller: _usernameController,
            icon: Icons.alternate_email,
            placeholder: 'auth_username_placeholder'.tr(),
            height: 50,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.x14),
          AppTextField(
            label: 'auth_password_label'.tr(),
            controller: _passwordController,
            icon: Icons.lock_outline,
            placeholder: '••••••',
            hint: 'auth_min_password_length_hint'.tr(),
            obscureText: true,
            canToggleObscure: true,
            height: 50,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppSpacing.x8),
            Text(
              _errorText!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StatusColors.overdue.color,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.x16),
          AppButton(
            label: 'auth_register_button'.tr(),
            height: 56,
            loading: _submitting,
            onPressed: _submit,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.x8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'auth_register_have_account'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: Text('auth_login_button'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterSuccessView extends StatelessWidget {
  const _RegisterSuccessView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
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
              child: Icon(
                Icons.check,
                size: 48,
                color: StatusColors.ready.color,
              ),
            ),
            const SizedBox(height: AppSpacing.x24),
            Text(
              'auth_register_success_title'.tr(),
              style: text.displaySmall?.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x8),
            SizedBox(
              width: 300,
              child: Text(
                'auth_register_success_message'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                  height: 1.5,
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
                onPressed: () => context.go(Routes.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

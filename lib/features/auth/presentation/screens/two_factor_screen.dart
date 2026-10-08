import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../data/local/local_auth_repository.dart';
import '../../domain/auth_exceptions.dart';
import '../providers/auth_providers.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _codeController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await ref
          .read(authSessionProvider.notifier)
          .completeTwoFactor(userId: widget.userId, code: code);
      if (!mounted) return;
      context.go(Routes.welcome);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final repo = ref.read(authRepositoryProvider);
    final devCode = kDebugMode && repo is LocalAuthRepository
        ? repo.debugLastTwoFactorCodeFor(widget.userId)
        : null;

    return Scaffold(
      appBar: AppTopBar(title: 'auth_2fa_title'.tr(), showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.x16),
            Text(
              'auth_2fa_subtitle'.tr(),
              style: text.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.x16),
            if (devCode != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x12),
                child: Text(
                  'Dev code (no real SMS yet): $devCode',
                  style: const TextStyle(
                    color: AppColors.amberDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            AppTextField(
              label: 'auth_2fa_code_label'.tr(),
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onSubmitted: (_) => _submit(),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: AppSpacing.x8),
              Text(
                _errorText!,
                style: TextStyle(color: StatusColors.overdue.color),
              ),
            ],
            const SizedBox(height: AppSpacing.x16),
            AppButton(
              label: 'auth_verify'.tr(),
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

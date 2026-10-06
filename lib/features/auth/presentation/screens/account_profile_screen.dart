import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/providers/active_branch_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/store_glyph.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';

const Color _teal = Color(0xFF0E8F8A);

class AccountProfileScreen extends ConsumerStatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  ConsumerState<AccountProfileScreen> createState() =>
      _AccountProfileScreenState();
}

class _AccountProfileScreenState extends ConsumerState<AccountProfileScreen> {
  bool _notifications = true;
  Branch? _branch;
  String? _resolvedForUserId;

  /// Resolves the branch to display once the signed-in user is actually available.
  Future<void> _resolveBranch(AuthUser user) async {
    final activeId = ref.read(activeBranchProvider);
    final branchId =
        activeId ?? (user.branchIds.isNotEmpty ? user.branchIds.first : null);
    if (branchId == null) return;
    final branch = await ref
        .read(appDatabaseProvider)
        .branchDao
        .getById(branchId);
    if (mounted) setState(() => _branch = branch);
  }

  void _leave() {
    final user = ref.read(authSessionProvider).value;
    if (context.canPop()) {
      context.pop();
    } else if (user != null) {
      context.go(shellRouteForRole(user.roleName));
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const _LogoutSheet(),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authSessionProvider.notifier).logout();
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).value;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.surface),
        ),
      );
    }

    if (_resolvedForUserId != user.id) {
      _resolvedForUserId = user.id;
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveBranch(user));
    }

    final role = _RoleStyle.of(user.roleName);
    final localeCode = ref.watch(localeProvider).languageCode;
    final branchName = _branch == null
        ? null
        : (localeCode == 'ne' ? _branch!.nameNe : _branch!.nameEn);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            user: user,
            role: role,
            localeCode: localeCode,
            branchName: branchName,
            onBack: _leave,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                const SizedBox(height: 14),
                _ContactSummary(username: user.username, phone: user.phone),
                _GroupLabel('auth_account_prefs'.tr()),
                _Card(
                  children: [
                    _Row(
                      icon: Icons.language,
                      tint: StatusColors.cutting.color,
                      title: 'auth_account_language'.tr(),
                      trailing: _LangSegment(localeCode: localeCode),
                    ),
                    _Row(
                      icon: Icons.notifications_outlined,
                      tint: StatusColors.stitching.color,
                      title: 'auth_account_notifs'.tr(),
                      subtitle: 'auth_account_notifs_sub'.tr(),
                      last: true,
                      trailing: _Toggle(
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                    ),
                  ],
                ),
                _GroupLabel('auth_account_section'.tr()),
                _Card(
                  children: [
                    _Row(
                      icon: Icons.lock_outline,
                      tint: AppColors.navy,
                      title: 'auth_account_change_pw'.tr(),
                      onTap: () => showAppToast(
                        context,
                        'auth_account_coming_soon'.tr(),
                      ),
                    ),
                    _Row(
                      icon: Icons.storefront_outlined,
                      iconWidget: const StoreGlyph(size: 19, color: _teal),
                      tint: _teal,
                      title: 'auth_account_branch'.tr(),
                      subtitle: branchName,
                      last: true,
                      onTap: () => showAppToast(
                        context,
                        'auth_account_coming_soon'.tr(),
                      ),
                    ),
                  ],
                ),
                _GroupLabel('auth_account_support'.tr()),
                _Card(
                  children: [
                    _Row(
                      icon: Icons.help_outline,
                      tint: StatusColors.cutting.color,
                      title: 'auth_account_help'.tr(),
                      onTap: () => showAppToast(
                        context,
                        'auth_account_coming_soon'.tr(),
                      ),
                    ),
                    _Row(
                      icon: Icons.phone_outlined,
                      tint: StatusColors.ready.color,
                      title: 'auth_account_contact'.tr(),
                      last: true,
                      onTap: () => showAppToast(
                        context,
                        'auth_account_coming_soon'.tr(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _LogoutButton(onTap: _confirmLogout),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'auth_account_version'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.faintText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStyle {
  const _RoleStyle({
    required this.color,
    required this.icon,
    required this.labelKey,
  });
  final Color color;
  final IconData icon;
  final String labelKey;

  static _RoleStyle of(String roleName) {
    switch (roleName) {
      case 'Admin':
        return const _RoleStyle(
          color: Color(0xFF5B47C7),
          icon: Icons.shield_outlined,
          labelKey: 'auth_role_admin_full',
        );
      case 'Production Worker':
        return const _RoleStyle(
          color: AppColors.amberDark,
          icon: Icons.content_cut,
          labelKey: 'auth_role_worker_full',
        );
      case 'Counter':
      default:
        return const _RoleStyle(
          color: _teal,
          icon: Icons.point_of_sale_outlined,
          labelKey: 'auth_role_counter_full',
        );
    }
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.user,
    required this.role,
    required this.localeCode,
    required this.branchName,
    required this.onBack,
  });

  final AuthUser user;
  final _RoleStyle role;
  final String localeCode;
  final String? branchName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'auth_account_title'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => ref.read(localeProvider.notifier).toggle(),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public,
                            size: 16,
                            color: AppColors.surface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localeCode == 'en' ? 'EN' : 'ने',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              child: Column(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface.withValues(alpha: 0.16),
                          ),
                          child: Text(
                            AppAvatar.initialsOf(user.name),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: GestureDetector(
                            onTap: () => showAppToast(
                              context,
                              'auth_account_coming_soon'.tr(),
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.amber,
                                border: Border.all(
                                  color: AppColors.navy,
                                  width: 2.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                size: 15,
                                color: AppColors.navyDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(role.icon, size: 14, color: AppColors.surface),
                            const SizedBox(width: 6),
                            Text(
                              role.labelKey.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (branchName != null && branchName!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StoreGlyph(
                              size: 15,
                              color: AppColors.surface.withValues(alpha: 0.78),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              branchName!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface.withValues(
                                  alpha: 0.78,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: AppColors.surface),
      ),
    );
  }
}

class _ContactSummary extends StatelessWidget {
  const _ContactSummary({required this.username, required this.phone});
  final String username;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: _cell('auth_account_username_label'.tr(), username),
            ),
            const VerticalDivider(width: 1, color: AppColors.hairline),
            Expanded(
              flex: 6,
              child: _cell('auth_account_phone_label'.tr(), phone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.faintText,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 20, 6, 9),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.faintText,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppRadii.card),
  border: Border.all(color: AppColors.hairline),
);

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.tint,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.last = false,
    this.iconWidget,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;

  /// Exact-SVG glyph override (e.g.
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: iconWidget ?? Icon(icon, size: 19, color: tint),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFC7CEDA),
                ),
          ],
        ),
      ),
    );
  }
}

class _LangSegment extends ConsumerWidget {
  const _LangSegment({required this.localeCode});
  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_seg(ref, 'EN', 'en'), _seg(ref, 'ने', 'ne')],
      ),
    );
  }

  Widget _seg(WidgetRef ref, String label, String code) {
    final selected = localeCode == code;
    return GestureDetector(
      onTap: selected
          ? null
          : () => ref
                .read(localeProvider.notifier)
                .setLocale(localeFromCode(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.navy : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? StatusColors.ready.color : const Color(0xFFCBD2DE),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final red = StatusColors.overdue.color;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.logout, size: 19, color: red),
        label: Text(
          'auth_account_logout'.tr(),
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF5F4),
          side: BorderSide(color: red.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card - 2),
          ),
        ),
      ),
    );
  }
}

class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    final red = StatusColors.overdue.color;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.sheet),
          topRight: Radius.circular(AppRadii.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DBE6),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF5F4),
                ),
                child: Icon(Icons.logout, size: 28, color: red),
              ),
              const SizedBox(height: 12),
              Text(
                'auth_account_logout_title'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 280,
                child: Text(
                  'auth_account_logout_message'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  // 5 : 6 ≈ the mockup's flex 1 : 1.2 (Cancel slightly narrower than the primary Log out action).
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.hairline),
                          foregroundColor: AppColors.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadii.card - 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'auth_account_cancel'.tr(),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.logout, size: 18),
                        label: Text(
                          'auth_account_logout'.tr(),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: AppColors.surface,
                          elevation: 6,
                          shadowColor: red.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadii.card - 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

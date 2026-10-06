import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/active_branch_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/indeterminate_loader_bar.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_providers.dart';

/// Step 6 — role router.
class WelcomeRedirectScreen extends ConsumerStatefulWidget {
  const WelcomeRedirectScreen({super.key});

  @override
  ConsumerState<WelcomeRedirectScreen> createState() =>
      _WelcomeRedirectScreenState();
}

class _WelcomeRedirectScreenState extends ConsumerState<WelcomeRedirectScreen> {
  static const _minDisplay = Duration(milliseconds: 1100);

  String? _branchDisplayName;
  bool _needsBranchSelection = false;
  bool _started = false;

  void _maybeStart(AuthUser user) {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _resolveAndAdvance(user),
    );
  }

  Future<void> _resolveAndAdvance(AuthUser user) async {
    final stopwatch = Stopwatch()..start();

    if (user.isAdmin || user.hasMultipleBranches || user.branchIds.isEmpty) {
      if (mounted) setState(() => _needsBranchSelection = true);
    } else {
      final branchId = user.branchIds.first;
      ref.read(activeBranchProvider.notifier).setBranch(branchId);
      final branch = await ref
          .read(appDatabaseProvider)
          .branchDao
          .getById(branchId);
      if (mounted) {
        final ne = context.locale.languageCode == 'ne';
        setState(
          () => _branchDisplayName = branch == null
              ? branchId
              : (ne ? branch.nameNe : branch.nameEn),
        );
      }
    }

    final elapsed = stopwatch.elapsed;
    if (elapsed < _minDisplay) {
      await Future<void>.delayed(_minDisplay - elapsed);
    }
    if (!mounted) return;
    context.go(
      _needsBranchSelection
          ? Routes.branchSelector
          : shellRouteForRole(user.roleName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).value;
    if (user == null) return const SizedBox.shrink(); // route guard covers this
    _maybeStart(user);

    final role = _RoleMeta.of(user.roleName);
    final branchLabel = _needsBranchSelection
        ? 'auth_welcome_branch_all'.tr()
        : (_branchDisplayName ?? '…');

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [AppColors.navy, AppColors.navyDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/branding/logo.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 9),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Stitch',
                          style: TextStyle(color: AppColors.surface),
                        ),
                        TextSpan(
                          text: 'Track',
                          style: TextStyle(color: AppColors.amber),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleAvatar(
                        name: user.name,
                        seed: user.id,
                        icon: role.icon,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'auth_welcome_greeting'.tr(),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0x99FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 9,
                        runSpacing: 9,
                        children: [
                          _AmberPill(icon: role.icon, label: role.fullLabel),
                          _BranchPill(label: branchLabel),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final r in _RoleMeta.all)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: _RoleTile(
                                meta: r,
                                active: r.roleName == user.roleName,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth_welcome_taking'.tr(),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xC7FFFFFF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          role.homeLabel,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.surface,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const IndeterminateLoaderBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleMeta {
  const _RoleMeta({
    required this.roleName,
    required this.icon,
    required this.tileLabel,
    required this.fullLabel,
    required this.homeLabel,
  });

  final String roleName;
  final IconData icon;
  final String tileLabel;
  final String fullLabel;
  final String homeLabel;

  static List<_RoleMeta> get all => [
    _RoleMeta(
      roleName: 'Admin',
      icon: Icons.shield_outlined,
      tileLabel: 'auth_role_admin_tile'.tr(),
      fullLabel: 'auth_role_admin_full'.tr(),
      homeLabel: 'auth_role_admin_home'.tr(),
    ),
    _RoleMeta(
      roleName: 'Counter',
      icon: Icons.storefront_outlined,
      tileLabel: 'auth_role_counter_tile'.tr(),
      fullLabel: 'auth_role_counter_full'.tr(),
      homeLabel: 'auth_role_counter_home'.tr(),
    ),
    _RoleMeta(
      roleName: 'Production Worker',
      icon: Icons.cut,
      tileLabel: 'auth_role_worker_tile'.tr(),
      fullLabel: 'auth_role_worker_full'.tr(),
      homeLabel: 'auth_role_worker_home'.tr(),
    ),
  ];

  static _RoleMeta of(String roleName) =>
      all.firstWhere((r) => r.roleName == roleName, orElse: () => all[1]);
}

class _RoleAvatar extends StatelessWidget {
  const _RoleAvatar({
    required this.name,
    required this.seed,
    required this.icon,
  });

  final String name;
  final String seed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.06),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(7),
            child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A4677), Color(0xFF1B2F54)],
                ),
              ),
              child: Text(
                AppAvatar.initialsOf(name),
                style: const TextStyle(
                  color: AppColors.surface,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber,
                border: Border.all(color: AppColors.navyDark, width: 3),
              ),
              child: Icon(icon, size: 17, color: AppColors.navyDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmberPill extends StatelessWidget {
  const _AmberPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.navyDark),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchPill extends StatelessWidget {
  const _BranchPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 15,
            color: AppColors.amber,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.meta, required this.active});
  final _RoleMeta meta;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.amber
                        : AppColors.surface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(17),
                    border: active
                        ? null
                        : Border.all(
                            color: AppColors.surface.withValues(alpha: 0.12),
                          ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    meta.icon,
                    size: 27,
                    color: active
                        ? AppColors.navyDark
                        : AppColors.surface.withValues(alpha: 0.34),
                  ),
                ),
                if (!active)
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2A3A5C),
                        border: Border.all(color: AppColors.navyDark, width: 2),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 11,
                        color: AppColors.surface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta.tileLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

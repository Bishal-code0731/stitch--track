import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/providers/active_branch_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../counter_workflow/presentation/screens/counter_shell_screen.dart';
import '../../../dashboard/presentation/screens/admin_shell_screen.dart';
import '../../../production_workflow/presentation/screens/production_shell_screen.dart';
import '../providers/auth_providers.dart';

Widget _backdropForRole(String roleName) {
  switch (roleName) {
    case 'Admin':
      return const AdminShellScreen();
    case 'Counter':
      return const CounterShellScreen();
    case 'Production Worker':
      return const ProductionShellScreen();
    default:
      return const SizedBox.shrink();
  }
}

class _BranchOption {
  const _BranchOption(
    this.id,
    this.nameEn,
    this.nameNe,
    this.addressEn,
    this.addressNe,
    this.activeOrders,
  );
  final String id;
  final String nameEn;
  final String nameNe;
  final String addressEn;
  final String addressNe;
  final int activeOrders;

  String name(bool ne) => ne ? nameNe : nameEn;
  String address(bool ne) => ne ? addressNe : addressEn;
}

/// Step 7 — searchable branch list with live active-order counts.
class BranchSelectorScreen extends ConsumerStatefulWidget {
  const BranchSelectorScreen({super.key});

  @override
  ConsumerState<BranchSelectorScreen> createState() =>
      _BranchSelectorScreenState();
}

class _BranchSelectorScreenState extends ConsumerState<BranchSelectorScreen> {
  List<_BranchOption>? _options;
  String _query = '';
  bool _allBranchesSelected = false;
  String? _selectedBranchId;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authSessionProvider).value;
    if (user == null) return;
    final db = ref.read(appDatabaseProvider);

    final allBranches = await db.branchDao.getAll();
    final visible = user.isAdmin
        ? allBranches.where((b) => b.isActive)
        : allBranches.where((b) => b.isActive && user.branchIds.contains(b.id));

    final options = <_BranchOption>[];
    for (final b in visible) {
      final items = await db.orderDao.getByBranch(b.id);
      final active = items
          .where(
            (o) =>
                o.status != OrderStatus.delivered &&
                o.status != OrderStatus.cancelled,
          )
          .length;
      options.add(
        _BranchOption(
          b.id,
          b.nameEn,
          b.nameNe,
          b.addressEn,
          b.addressNe,
          active,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _options = options;
      _isAdmin = user.isAdmin;
      _allBranchesSelected = user.isAdmin;
      _selectedBranchId = user.isAdmin
          ? null
          : (options.isNotEmpty ? options.first.id : null);
    });
  }

  void _confirm() {
    ref
        .read(activeBranchProvider.notifier)
        .setBranch(_allBranchesSelected ? null : _selectedBranchId);
    final user = ref.read(authSessionProvider).value;
    if (user == null) return;
    context.go(shellRouteForRole(user.roleName));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authSessionProvider).value;
    final ne = context.locale.languageCode == 'ne';
    final options = _options;
    final query = _query.trim();
    final filtered = options == null
        ? const <_BranchOption>[]
        : options
              .where(
                (o) => o.name(ne).toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    final showAll = _isAdmin && query.isEmpty;
    final canConfirm = _allBranchesSelected || _selectedBranchId != null;
    final totalActive =
        options?.fold<int>(0, (sum, o) => sum + o.activeOrders) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Stack(
        children: [
          if (user != null)
            Positioned.fill(
              child: IgnorePointer(child: _backdropForRole(user.roleName)),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.84,
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.sheet),
                    topRight: Radius.circular(AppRadii.sheet),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: options == null
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD5DBE6),
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'auth_branch_selector_title'.tr(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'auth_branch_selector_subtitle'.tr(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.mutedText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: canConfirm ? _confirm : null,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF1F3F8),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                              child: AppSearchBar(
                                hintText: 'auth_branch_selector_search_hint'
                                    .tr(),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            Flexible(
                              child: (filtered.isEmpty && !showAll)
                                  ? _EmptyState(
                                      text: 'auth_branch_selector_none'.tr(),
                                    )
                                  : ListView(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.fromLTRB(
                                        18,
                                        6,
                                        18,
                                        8,
                                      ),
                                      children: [
                                        if (showAll) ...[
                                          _BranchRow(
                                            icon: Icons.grid_view_rounded,
                                            name: 'auth_branch_selector_all'
                                                .tr(),
                                            subtitle:
                                                'auth_branch_selector_all_sub'
                                                    .tr(
                                                      namedArgs: {
                                                        'n':
                                                            '${options.length}',
                                                      },
                                                    ),
                                            count: totalActive,
                                            selected: _allBranchesSelected,
                                            onTap: () => setState(() {
                                              _allBranchesSelected = true;
                                              _selectedBranchId = null;
                                            }),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 4,
                                            ),
                                            child: Divider(
                                              height: 1,
                                              color: AppColors.hairline,
                                            ),
                                          ),
                                        ],
                                        for (final o in filtered)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: AppSpacing.x10,
                                            ),
                                            child: _BranchRow(
                                              icon: Icons.storefront_outlined,
                                              name: o.name(ne),
                                              subtitle: o.address(ne),
                                              count: o.activeOrders,
                                              selected:
                                                  !_allBranchesSelected &&
                                                  _selectedBranchId == o.id,
                                              onTap: () => setState(() {
                                                _allBranchesSelected = false;
                                                _selectedBranchId = o.id;
                                              }),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                12,
                                18,
                                16,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.hairline),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: canConfirm ? _confirm : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: AppColors.surface,
                                    disabledBackgroundColor: AppColors.hairline,
                                    elevation: 0,
                                    shadowColor: AppColors.navy.withValues(
                                      alpha: 0.25,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.largeCard - 5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'auth_branch_selector_confirm'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 36,
            color: AppColors.faintText.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.faintText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final String subtitle;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEEF2FA) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.navy : const Color(0xFFEEF1F6),
                  borderRadius: BorderRadius.circular(13),
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
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CountChip(count: count),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.navy : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(color: const Color(0xFFCFD6E2), width: 2),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.surface,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountChip extends StatefulWidget {
  const _CountChip({required this.count});
  final int count;

  @override
  State<_CountChip> createState() => _CountChipState();
}

class _CountChipState extends State<_CountChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) return;
    _animationStarted = true;
    if (!MediaQuery.disableAnimationsOf(context))
      _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: StatusColors.ready.chipBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Opacity(
              opacity: 0.45 + (0.55 * (1 - _controller.value)),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StatusColors.ready.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'auth_branch_active_count'.tr(args: ['${widget.count}']),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: StatusColors.ready.color,
            ),
          ),
        ],
      ),
    );
  }
}

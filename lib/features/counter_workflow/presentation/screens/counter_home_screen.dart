import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/shadows.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/numerals.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/store_glyph.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_wizard_provider.dart';
import '../demo/counter_home_demo.dart';

class CounterHomeScreen extends ConsumerWidget {
  const CounterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final lang = locale.languageCode;
    final user = ref.watch(authSessionProvider).value;
    final initials = user == null ? 'AM' : AppAvatar.initialsOf(user.name);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            _Header(lang: lang, initials: initials),
            Expanded(
              child: _Body(lang: lang, locale: locale),
            ),
          ],
        ),
      ),
    );
  }
}

/// The amber pill "New Order" FAB from the mockup.
class NewOrderFab extends ConsumerWidget {
  const NewOrderFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(224, 168, 0, 0.42),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            ref.read(orderWizardProvider.notifier).reset();
            context.push(Routes.newOrder);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 22, color: AppColors.navyDark),
                const SizedBox(width: 9),
                Text(
                  'counter_home_new_order'.tr(),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Header

class _Header extends StatelessWidget {
  const _Header({required this.lang, required this.initials});

  final String lang;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      padding: EdgeInsets.only(top: topPad + 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              children: [
                Expanded(child: _BranchButton(lang: lang)),
                const SizedBox(width: 10),
                const _LangButton(),
                const SizedBox(width: 10),
                _AccountAvatar(initials: initials),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 16),
            child: _SearchField(lang: lang),
          ),
        ],
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  const _BranchButton({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(Routes.branchSelector),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              const StoreGlyph(size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'counter_home_branch_label'.tr(),
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      demoCounterBranch.resolve(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.surface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Globe + EN/ने single-button language toggle, matching the mockup (and the Account Profile header).
class _LangButton extends ConsumerWidget {
  const _LangButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    return Semantics(
      label: 'language'.tr(),
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.read(localeProvider.notifier).toggle(),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.surface.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 17, color: AppColors.surface),
              const SizedBox(width: 6),
              Text(
                code == 'en' ? 'EN' : 'ने',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context.push(Routes.account),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface.withValues(alpha: 0.18),
        ),
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showAppToast(context, 'auth_account_coming_soon'.tr()),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.12),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: AppColors.faintText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'counter_home_search_hint'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.faintText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Body

class _Body extends StatelessWidget {
  const _Body({required this.lang, required this.locale});

  final String lang;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Bottom padding clears the FAB + bottom nav so the last card is visible.
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
      children: [
        _StatsGrid(lang: lang, locale: locale),
        const SizedBox(height: 20),
        _RecentHeader(),
        const SizedBox(height: 11),
        for (final order in demoRecentOrders) ...[
          _OrderCard(order: order, lang: lang),
          if (order != demoRecentOrders.last) const SizedBox(height: 11),
        ],
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.lang, required this.locale});

  final String lang;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.assignment_outlined,
        value: numerals(demoTodayOrders, locale),
        label: 'counter_home_stat_today'.tr(),
        tone: AppColors.navy,
      ),
      _StatCard(
        icon: Icons.straighten,
        value: numerals(demoTrialsToday, locale),
        label: 'counter_home_stat_trials'.tr(),
        tone: StatusColors.cutting.color,
      ),
      _StatCard(
        icon: Icons.shopping_bag_outlined,
        value: numerals(demoReadyForPickup, locale),
        label: 'counter_home_stat_ready'.tr(),
        tone: StatusColors.ready.color,
      ),
      _StatCard(
        icon: Icons.payments_outlined,
        value: formatMoney(demoPendingBalance, locale),
        label: 'counter_home_stat_balance'.tr(),
        tone: AppColors.amberDark,
      ),
    ];

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 10),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 10),
              Expanded(child: cards[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: tone),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'counter_home_recent'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            onTap: () => showAppToast(context, 'auth_account_coming_soon'.tr()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'counter_home_see_all'.tr(),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.navy,
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.lang});

  final CounterHomeOrder order;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final status = order.status.colors;
    final blue = StatusColors.cutting.color;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => showAppToast(context, 'auth_account_coming_soon'.tr()),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.hairline),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (order.priority) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.bolt, size: 15, color: AppColors.amber),
                  ],
                  const Spacer(),
                  _StatusPill(
                    status: status,
                    label: order.status.labelKey.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue.withValues(alpha: 0.10),
                    ),
                    child: Text(
                      order.initials,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.customerName.resolve(lang),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Icon(
                              Icons.sell_outlined,
                              size: 13,
                              color: AppColors.navy,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _itemsLine(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (order.overdue
                                ? 'counter_home_overdue'
                                : 'counter_home_due')
                            .tr(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faintText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        order.due.resolve(lang),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: order.overdue
                              ? StatusColors.overdue.color
                              : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "2 items: Daura Suruwal, Trouser" — count pluralised, then the summary.
  String _itemsLine() {
    final count = numerals(order.itemCount, localeFromCode(lang));
    final unit =
        (order.itemCount > 1 ? 'counter_home_items' : 'counter_home_item').tr();
    return '$count $unit: ${order.items.resolve(lang)}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label});

  final StatusColor status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.chipBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: status.chipText,
            ),
          ),
        ],
      ),
    );
  }
}

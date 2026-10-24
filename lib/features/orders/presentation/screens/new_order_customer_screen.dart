import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numerals.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../providers/order_wizard_provider.dart';
import '../widgets/order_wizard_stepper.dart';

class NewOrderCustomerScreen extends ConsumerStatefulWidget {
  const NewOrderCustomerScreen({super.key});

  @override
  ConsumerState<NewOrderCustomerScreen> createState() =>
      _NewOrderCustomerScreenState();
}

class _NewOrderCustomerScreenState
    extends ConsumerState<NewOrderCustomerScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addNew() async {
    final created = await context.push<CustomerEntity>(Routes.addCustomer);
    if (created != null) {
      ref.read(orderWizardProvider.notifier).selectCustomer(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(orderWizardProvider).customer;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: selected == null
                  ? _PickerBody(
                      controller: _search,
                      query: _query,
                      onQuery: (v) => setState(() => _query = v),
                      onAddNew: _addNew,
                      onSelect: (c) => ref
                          .read(orderWizardProvider.notifier)
                          .selectCustomer(c),
                    )
                  : _SelectedBody(
                      customer: selected,
                      onChange: () => ref
                          .read(orderWizardProvider.notifier)
                          .clearCustomer(),
                    ),
            ),
            if (selected != null) const _ContinueFooter(),
          ],
        ),
      ),
    );
  }
}

// Header (back + title + step + lang + stepper)

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.paddingOf(context).top;
    final code = ref.watch(localeProvider).languageCode;
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(top: topPad + 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Material(
                  color: AppColors.surface.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 19,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'neworder_title'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surface,
                        ),
                      ),
                      Text(
                        'neworder_step_of_customer'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.surface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  label: 'language'.tr(),
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => ref.read(localeProvider.notifier).toggle(),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        code == 'en' ? 'EN' : 'ने',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: OrderWizardStepper(activeIndex: 0),
          ),
        ],
      ),
    );
  }
}

// Picker body (search + add-new + results)

class _PickerBody extends ConsumerWidget {
  const _PickerBody({
    required this.controller,
    required this.query,
    required this.onQuery,
    required this.onAddNew,
    required this.onSelect,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQuery;
  final VoidCallback onAddNew;
  final ValueChanged<CustomerEntity> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final results = ref.watch(customerPickerResultsProvider(query));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          'neworder_find'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'neworder_find_sub'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 14),
        _SearchField(controller: controller, query: query, onQuery: onQuery),
        const SizedBox(height: 12),
        _AddNewButton(onTap: onAddNew),
        const SizedBox(height: 20),
        results.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(child: Text('state_error_title'.tr())),
          ),
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 10),
                child: Text(
                  '${'neworder_results'.tr()} · '
                  '${numerals(items.length, localeFromCode(lang))}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.faintText,
                  ),
                ),
              ),
              if (items.isEmpty)
                const _EmptyResults()
              else
                for (final item in items) ...[
                  _CustomerRow(
                    item: item,
                    lang: lang,
                    onTap: () => onSelect(item.customer),
                  ),
                  if (item != items.last) const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.query,
    required this.onQuery,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(20, 40, 80, 0.04),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.faintText),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onQuery,
              style: const TextStyle(fontSize: 15.5, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'neworder_search_ph'.tr(),
                hintStyle: const TextStyle(color: AppColors.faintText),
              ),
            ),
          ),
          if (query.isNotEmpty)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                controller.clear();
                onQuery('');
              },
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF1F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 13,
                  color: AppColors.mutedText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddNewButton extends StatelessWidget {
  const _AddNewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: DottedBorderBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20, color: AppColors.navy),
            const SizedBox(width: 9),
            Text(
              'neworder_add_new'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dashed-border tinted box (the design's "Add new customer" CTA).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: AppColors.navy.withValues(alpha: 0.30),
        radius: 14,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FA),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) =>
      old.color != color || old.radius != radius;
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.item,
    required this.lang,
    required this.onTap,
  });

  final CustomerPickerItem item;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = item.customer;
    final last = item.lastOrderDate;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(20, 40, 80, 0.04),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              AppAvatar(name: c.name, seed: c.id, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      c.phonePrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: AppColors.faintText,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            last == null
                                ? '${'neworder_orders'.tr()} · '
                                      '${numerals(item.orderCount, localeFromCode(lang))}'
                                : '${'neworder_last_order'.tr()} · '
                                      '${formatShortDate(last, localeFromCode(lang))}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.faintText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.faintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 36,
            color: AppColors.faintText.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
          Text(
            'neworder_none'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'neworder_none_sub'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.faintText,
            ),
          ),
        ],
      ),
    );
  }
}

// Selected-customer body

class _SelectedBody extends ConsumerWidget {
  const _SelectedBody({required this.customer, required this.onChange});

  final CustomerEntity customer;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final stats = ref.watch(customerStatsProvider(customer.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: StatusColors.ready.chipBackground,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 16, color: StatusColors.ready.chipText),
              const SizedBox(width: 7),
              Text(
                'neworder_selected'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: StatusColors.ready.chipText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.navy, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(31, 56, 100, 0.12),
                offset: Offset(0, 6),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AppAvatar(name: customer.name, seed: customer.id, size: 58),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 19,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.call_outlined,
                              size: 15,
                              color: AppColors.navy,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                customer.phonePrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mutedText,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChangeButton(onTap: onChange),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: Icons.shopping_bag_outlined,
                      label: 'neworder_past_orders'.tr(),
                      value: stats.when(
                        data: (s) => numerals(s.count, localeFromCode(lang)),
                        loading: () => '—',
                        error: (_, _) => '—',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      icon: Icons.schedule,
                      label: 'neworder_last_order'.tr(),
                      value: stats.when(
                        data: (s) => s.last == null
                            ? '—'
                            : formatShortDate(s.last!, localeFromCode(lang)),
                        loading: () => '—',
                        error: (_, _) => '—',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined, size: 15, color: AppColors.navy),
              const SizedBox(width: 5),
              Text(
                'neworder_change'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueFooter extends StatelessWidget {
  const _ContinueFooter();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      child: Material(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => context.push(Routes.newOrderGarments),
          child: SizedBox(
            height: 54,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'neworder_continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.chevron_right,
                    size: 19,
                    color: AppColors.surface,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

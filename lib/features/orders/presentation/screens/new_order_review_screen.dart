import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/numerals.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/garment_template_entity.dart';
import '../../domain/entities/order_pricing.dart';
import '../providers/order_providers.dart';
import '../providers/order_wizard_provider.dart';
import '../widgets/order_wizard_header.dart';
import 'new_order_measurements_screen.dart' show measurementFieldLabel;

class NewOrderReviewScreen extends ConsumerStatefulWidget {
  const NewOrderReviewScreen({super.key});

  @override
  ConsumerState<NewOrderReviewScreen> createState() =>
      _NewOrderReviewScreenState();
}

class _NewOrderReviewScreenState extends ConsumerState<NewOrderReviewScreen> {
  int? _expanded; // uid of the expanded garment card

  @override
  void initState() {
    super.initState();
    // Default the trial/delivery dates on first entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderWizardProvider.notifier)
          .ensureScheduleDefaults(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final locale = localeFromCode(lang);
    final wizard = ref.watch(orderWizardProvider);
    final controller = ref.read(orderWizardProvider.notifier);
    final templates =
        ref.watch(activeGarmentTemplatesProvider).value ??
        const <GarmentTemplateEntity>[];
    final byId = {for (final t in templates) t.id: t};

    final subtotal = orderSubtotal(
      wizard.garments.map(
        (g) =>
            (price: byId[g.templateId]?.basePrice ?? 0, quantity: g.quantity),
      ),
    );
    final pricing = OrderPricing.compute(
      subtotal: subtotal,
      discount: wizard.discount,
      vatRate: AppConfig.defaultVatRate,
    );
    final balance = pricing.balanceAfter(wizard.advanceAmount);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            OrderWizardHeader(
              stepIndex: 3,
              subtitle: 'neworder_step_of_review'.tr(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _SectionTitle(
                    title: 'review_customer'.tr(),
                    onEdit: () => context.go(Routes.newOrder),
                  ),
                  if (wizard.customer != null)
                    _CustomerCard(
                      name: wizard.customer!.name,
                      phone: wizard.customer!.phonePrimary,
                      seed: wizard.customer!.id,
                    ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title:
                        '${'review_garments'.tr()} · ${wizard.garments.length}',
                    onEdit: () => context.go(Routes.newOrderGarments),
                  ),
                  for (final g in wizard.garments) ...[
                    _GarmentCard(
                      template: byId[g.templateId],
                      garment: g,
                      unit: wizard.unit,
                      lang: lang,
                      locale: locale,
                      expanded: _expanded == g.uid,
                      onToggle: () => setState(
                        () => _expanded = _expanded == g.uid ? null : g.uid,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 6),
                  _SectionTitle(title: 'review_pricing'.tr()),
                  _PricingCard(
                    pricing: pricing,
                    locale: locale,
                    onDiscount: (d) => controller.setDiscount(d),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'review_payment'.tr()),
                  _PaymentCard(
                    advance: wizard.advanceAmount,
                    balance: balance,
                    total: pricing.total,
                    mode: wizard.advanceMode,
                    locale: locale,
                    onAdvance: controller.setAdvance,
                    onMode: controller.setAdvanceMode,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'review_schedule'.tr()),
                  _ScheduleCard(
                    trial: wizard.trialDate,
                    delivery: wizard.deliveryDate,
                    locale: locale,
                    onTrial: controller.setTrialDate,
                    onDelivery: controller.setDeliveryDate,
                  ),
                  const SizedBox(height: 16),
                  _WhatsAppCard(
                    phone: wizard.customer?.phonePrimary ?? '',
                    on: wizard.sendWhatsApp,
                    onToggle: controller.setSendWhatsApp,
                  ),
                ],
              ),
            ),
            _Footer(
              total: formatMoney(pricing.total, locale),
              onConfirm: () =>
                  showAppToast(context, 'auth_account_coming_soon'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// Section title + shared card

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onEdit});

  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.faintText,
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.navy,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'review_edit'.tr(),
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
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: AppColors.hairline),
  boxShadow: const [
    BoxShadow(
      color: Color.fromRGBO(20, 40, 80, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ],
);

// Customer

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.name,
    required this.phone,
    required this.seed,
  });

  final String name;
  final String phone;
  final String seed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          AppAvatar(name: name, seed: seed, size: 46),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.call_outlined,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }
}

// Garment (expandable)

class _GarmentCard extends StatelessWidget {
  const _GarmentCard({
    required this.template,
    required this.garment,
    required this.unit,
    required this.lang,
    required this.locale,
    required this.expanded,
    required this.onToggle,
  });

  final GarmentTemplateEntity? template;
  final WizardGarment garment;
  final GarmentUnit unit;
  final String lang;
  final Locale locale;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final price = (template?.basePrice ?? 0) * garment.quantity;
    final unitLabel =
        (unit == GarmentUnit.inch ? 'measure_in_abbr' : 'measure_cm_abbr').tr();
    final entries = garment.measurements.entries.toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sell_outlined,
                      size: 21,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${template?.name(lang) ?? '—'}'
                          '${garment.quantity > 1 ? ' ×${numerals(garment.quantity, locale)}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 13,
                              color: StatusColors.cutting.chipText,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${numerals(entries.length, locale)} '
                                '${'review_measurements'.tr()}'
                                '${garment.note.isNotEmpty ? ' · ${garment.note}' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: StatusColors.cutting.chipText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(price, locale),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.faintText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 1, color: AppColors.hairline),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in entries)
                        _MeasureChip(
                          label: measurementFieldLabel(e.key),
                          value:
                              '${numerals(_fmt(e.value), locale)} $unitLabel',
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _MeasureChip extends StatelessWidget {
  const _MeasureChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // 3-up grid feel via a fixed-ish width; wraps on narrow screens.
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
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

// Pricing

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.pricing,
    required this.locale,
    required this.onDiscount,
  });

  final OrderPricing pricing;
  final Locale locale;
  final ValueChanged<double> onDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _row('review_subtotal'.tr(), formatMoney(pricing.subtotal, locale)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: 16,
                      color: StatusColors.ready.color,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'review_discount'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                _MiniStepper(
                  text: '− ${formatMoney(pricing.discount, locale)}',
                  color: StatusColors.ready.color,
                  onMinus: () => onDiscount(pricing.discount - 100),
                  onPlus: () => onDiscount(pricing.discount + 100),
                ),
              ],
            ),
          ),
          _row('review_vat'.tr(), formatMoney(pricing.vatAmount, locale)),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: AppColors.hairline),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'review_total'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  formatMoney(pricing.total, locale),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
    required this.text,
    required this.color,
    required this.onMinus,
    required this.onPlus,
  });

  final String text;
  final Color color;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _b(Icons.remove, onMinus),
          Container(
            constraints: const BoxConstraints(minWidth: 64),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _b(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _b(IconData icon, VoidCallback onTap) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, size: 15, color: AppColors.navy),
      ),
    ),
  );
}

// Payment

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.advance,
    required this.balance,
    required this.total,
    required this.mode,
    required this.locale,
    required this.onAdvance,
    required this.onMode,
  });

  final double advance;
  final double balance;
  final double total;
  final PaymentMode mode;
  final Locale locale;
  final ValueChanged<double> onAdvance;
  final ValueChanged<PaymentMode> onMode;

  @override
  Widget build(BuildContext context) {
    const modes = [
      (PaymentMode.cash, Icons.payments_outlined, 'review_cash'),
      (PaymentMode.card, Icons.credit_card, 'review_card'),
      (PaymentMode.upi, Icons.qr_code_2, 'review_upi'),
      (PaymentMode.bank, Icons.account_balance_outlined, 'review_bank'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'review_advance'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              _MiniStepper(
                text: formatMoney(advance, locale),
                color: AppColors.ink,
                onMinus: () => onAdvance(advance - 500),
                onPlus: () => onAdvance((advance + 500).clamp(0, total)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'review_balance'.tr(),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  formatMoney(balance, locale),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'review_mode'.tr(),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.faintText,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var i = 0; i < modes.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ModeChip(
                    icon: modes[i].$2,
                    label: modes[i].$3.tr(),
                    selected: mode == modes[i].$1,
                    onTap: () => onMode(modes[i].$1),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEEF2FA) : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? AppColors.navy : AppColors.mutedText,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.navy : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Schedule

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.trial,
    required this.delivery,
    required this.locale,
    required this.onTrial,
    required this.onDelivery,
  });

  final DateTime? trial;
  final DateTime? delivery;
  final Locale locale;
  final ValueChanged<DateTime> onTrial;
  final ValueChanged<DateTime> onDelivery;

  Future<void> _pick(
    BuildContext context,
    DateTime? current,
    ValueChanged<DateTime> onPick,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _ScheduleRow(
            icon: Icons.straighten,
            tint: const Color(0xFFEAF0FB),
            iconColor: StatusColors.cutting.chipText,
            label: 'review_trial'.tr(),
            value: trial == null ? '—' : formatShortDate(trial!, locale),
            onTap: () => _pick(context, trial, onTrial),
          ),
          const Divider(height: 1, color: AppColors.hairline),
          _ScheduleRow(
            icon: Icons.local_shipping_outlined,
            tint: const Color(0xFFFFF4DC),
            iconColor: AppColors.amberDark,
            label: 'review_delivery'.tr(),
            value: delivery == null ? '—' : formatShortDate(delivery!, locale),
            onTap: () => _pick(context, delivery, onDelivery),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.faintText,
            ),
          ],
        ),
      ),
    );
  }
}

// WhatsApp toggle

class _WhatsAppCard extends StatelessWidget {
  const _WhatsAppCard({
    required this.phone,
    required this.on,
    required this.onToggle,
  });

  final String phone;
  final bool on;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final wa = StatusColors.whatsapp.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: wa.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chat_outlined, size: 22, color: wa),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'review_wa_title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'review_wa_sub'.tr(namedArgs: {'phone': phone}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Switch(value: on, onChanged: onToggle, activeTrackColor: wa),
        ],
      ),
    );
  }
}

// Footer

class _Footer extends StatelessWidget {
  const _Footer({required this.total, required this.onConfirm});

  final String total;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'review_total'.tr(),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.faintText,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Material(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onConfirm,
                child: SizedBox(
                  height: 54,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.navyDark,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'review_confirm'.tr(),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDark,
                          ),
                        ),
                      ],
                    ),
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

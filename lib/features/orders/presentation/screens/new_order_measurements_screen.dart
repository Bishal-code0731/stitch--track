import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/numerals.dart';
import '../../domain/entities/garment_template_entity.dart';
import '../../domain/entities/measurement_utils.dart';
import '../providers/order_providers.dart';
import '../providers/order_wizard_provider.dart';
import '../widgets/garment_glyph.dart';
import '../widgets/order_wizard_header.dart';

/// Bilingual label for a measurement field id.
String measurementFieldLabel(String id) {
  const known = {
    'chest',
    'waist',
    'shoulder',
    'sleeve',
    'length',
    'collar',
    'hip',
    'thigh',
    'bust',
    'bottom',
    'inseam',
    'neck',
  };
  if (known.contains(id)) return 'mfield_$id'.tr();
  return id.isEmpty ? id : id[0].toUpperCase() + id.substring(1);
}

class NewOrderMeasurementsScreen extends ConsumerStatefulWidget {
  const NewOrderMeasurementsScreen({super.key});

  @override
  ConsumerState<NewOrderMeasurementsScreen> createState() =>
      _NewOrderMeasurementsScreenState();
}

class _NewOrderMeasurementsScreenState
    extends ConsumerState<NewOrderMeasurementsScreen> {
  int _tabIndex = 0;
  String? _activeField;
  final Set<int> _reused = {};
  final Set<int> _dismissedReuse = {};

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

    if (wizard.garments.isEmpty) {
      // Shouldn't happen (reached only after Step 2), but guard anyway.
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final index = _tabIndex.clamp(0, wizard.garments.length - 1);
    final garment = wizard.garments[index];
    final template = byId[garment.templateId];
    final fields = template == null
        ? const <String>[]
        : parseTemplateFields(template.fieldsJson);
    final unit = wizard.unit;
    final filled = fields.where((f) => garment.measurements[f] != null).length;
    final activeField =
        _activeField ?? (fields.isNotEmpty ? fields.first : null);

    final reuse = wizard.customer == null
        ? const AsyncValue.data(null)
        : ref.watch(
            lastMeasurementsProvider((
              customerId: wizard.customer!.id,
              templateId: garment.templateId,
            )),
          );
    final last = reuse.value;
    final showReuse =
        last != null &&
        !_reused.contains(garment.uid) &&
        !_dismissedReuse.contains(garment.uid);

    final isLast = index == wizard.garments.length - 1;
    final nextTemplate = isLast
        ? null
        : byId[wizard.garments[index + 1].templateId];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            OrderWizardHeader(
              stepIndex: 2,
              subtitle: 'neworder_step_of_measure'.tr(),
              bottom: _GarmentTabs(
                garments: wizard.garments,
                templates: byId,
                fieldsOf: (tid) => byId[tid] == null
                    ? const []
                    : parseTemplateFields(byId[tid]!.fieldsJson),
                activeIndex: index,
                lang: lang,
                locale: locale,
                onSelect: (i) => setState(() {
                  _tabIndex = i;
                  _activeField = null;
                }),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _DiagramCard(
                    template: template,
                    filled: filled,
                    total: fields.length,
                    unit: unit,
                    lang: lang,
                    locale: locale,
                    onUnit: controller.setUnit,
                  ),
                  const SizedBox(height: 14),
                  if (showReuse)
                    _ReuseCard(
                      customerName: wizard.customer!.name,
                      garmentName: template?.name(lang) ?? '',
                      date: formatShortDate(last.orderDate, locale),
                      onReuse: () {
                        controller.reuseMeasurements(garment.uid, last.values);
                        setState(() => _reused.add(garment.uid));
                      },
                      onDismiss: () =>
                          setState(() => _dismissedReuse.add(garment.uid)),
                    )
                  else if (_reused.contains(garment.uid))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReusedChip(),
                    ),
                  for (final f in fields) ...[
                    _MField(
                      label: measurementFieldLabel(f),
                      value: garment.measurements[f],
                      lastValue: last?.values[f],
                      unit: unit,
                      active: activeField == f,
                      lang: lang,
                      locale: locale,
                      onFocus: () => setState(() => _activeField = f),
                      onChange: (v) {
                        controller.setMeasurement(garment.uid, f, v);
                        setState(() => _activeField = f);
                      },
                    ),
                    if (f != fields.last) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  _SaveTemplateCard(
                    checked: garment.saveAsTemplate,
                    garmentName: template?.name(lang) ?? '',
                    onToggle: () => controller.setSaveAsTemplate(
                      garment.uid,
                      !garment.saveAsTemplate,
                    ),
                  ),
                ],
              ),
            ),
            _Footer(
              label: isLast
                  ? 'measure_review'.tr()
                  : '${'measure_next'.tr()} · ${nextTemplate?.name(lang) ?? ''}',
              onTap: () {
                if (isLast) {
                  context.push(Routes.newOrderReview);
                } else {
                  setState(() {
                    _tabIndex = index + 1;
                    _activeField = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Garment tabs (in the navy header)

class _GarmentTabs extends StatelessWidget {
  const _GarmentTabs({
    required this.garments,
    required this.templates,
    required this.fieldsOf,
    required this.activeIndex,
    required this.lang,
    required this.locale,
    required this.onSelect,
  });

  final List<WizardGarment> garments;
  final Map<String, GarmentTemplateEntity> templates;
  final List<String> Function(String templateId) fieldsOf;
  final int activeIndex;
  final String lang;
  final Locale locale;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < garments.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _GarmentTab(
              name: templates[garments[i].templateId]?.name(lang) ?? '—',
              index: i,
              locale: locale,
              active: i == activeIndex,
              done: () {
                final fields = fieldsOf(garments[i].templateId);
                return fields.isNotEmpty &&
                    fields.every((f) => garments[i].measurements[f] != null);
              }(),
              onTap: () => onSelect(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _GarmentTab extends StatelessWidget {
  const _GarmentTab({
    required this.name,
    required this.index,
    required this.locale,
    required this.active,
    required this.done,
    required this.onTap,
  });

  final String name;
  final int index;
  final Locale locale;
  final bool active;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? AppColors.surface
          : AppColors.surface.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? StatusColors.ready.color
                      : active
                      ? const Color(0xFFE8ECF4)
                      : AppColors.surface.withValues(alpha: 0.2),
                ),
                child: done
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.surface,
                      )
                    : Text(
                        numerals(index + 1, locale),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: active ? AppColors.navy : AppColors.surface,
                        ),
                      ),
              ),
              const SizedBox(width: 7),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.navy
                      : AppColors.surface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Diagram card (glyph + progress + unit toggle)

class _DiagramCard extends StatelessWidget {
  const _DiagramCard({
    required this.template,
    required this.filled,
    required this.total,
    required this.unit,
    required this.lang,
    required this.locale,
    required this.onUnit,
  });

  final GarmentTemplateEntity? template;
  final int filled;
  final int total;
  final GarmentUnit unit;
  final String lang;
  final Locale locale;
  final ValueChanged<GarmentUnit> onUnit;

  @override
  Widget build(BuildContext context) {
    final done = filled > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
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
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 108,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: GarmentGlyph(
              kind: garmentGlyphFor(template?.nameEn ?? ''),
              size: 56,
              color: AppColors.navy,
              strokeWidth: 1.6,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template?.name(lang) ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${numerals(filled, locale)}/${numerals(total, locale)} '
                  '${'measure_measured'.tr()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? StatusColors.ready.color
                        : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 12),
                _UnitToggle(unit: unit, onUnit: onUnit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onUnit});

  final GarmentUnit unit;
  final ValueChanged<GarmentUnit> onUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F6),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitButton(
            label: 'measure_unit_in'.tr(),
            selected: unit == GarmentUnit.inch,
            onTap: () => onUnit(GarmentUnit.inch),
          ),
          _UnitButton(
            label: 'measure_unit_cm'.tr(),
            selected: unit == GarmentUnit.cm,
            onTap: () => onUnit(GarmentUnit.cm),
          ),
        ],
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.surface : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

// Reuse suggestion

class _ReuseCard extends StatelessWidget {
  const _ReuseCard({
    required this.customerName,
    required this.garmentName,
    required this.date,
    required this.onReuse,
    required this.onDismiss,
  });

  final String customerName;
  final String garmentName;
  final String date;
  final VoidCallback onReuse;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final firstName = customerName.trim().split(RegExp(r'\s+')).first;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E6), Color(0xFFFFFDF7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DFA8), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.refresh,
              size: 21,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'measure_reuse_title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5A4A12),
                  ),
                ),
                Text(
                  'measure_reuse_sub'.tr(
                    namedArgs: {
                      'name': firstName,
                      'garment': garmentName,
                      'date': date,
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.amberDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: onReuse,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Text(
                  'measure_reuse'.tr(),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 17, color: AppColors.amberDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReusedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: StatusColors.ready.chipBackground,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: StatusColors.ready.chipText),
            const SizedBox(width: 7),
            Text(
              'measure_reused'.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: StatusColors.ready.chipText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Measurement field

class _MField extends StatelessWidget {
  const _MField({
    required this.label,
    required this.value,
    required this.lastValue,
    required this.unit,
    required this.active,
    required this.lang,
    required this.locale,
    required this.onFocus,
    required this.onChange,
  });

  final String label;
  final double? value;
  final double? lastValue;
  final GarmentUnit unit;
  final bool active;
  final String lang;
  final Locale locale;
  final VoidCallback onFocus;
  final ValueChanged<double> onChange;

  @override
  Widget build(BuildContext context) {
    final step = stepFor(unit);
    final unitLabel =
        (unit == GarmentUnit.inch ? 'measure_in_abbr' : 'measure_cm_abbr').tr();

    final String subtitle;
    if (value == null && lastValue == null) {
      subtitle = 'measure_not_set'.tr();
    } else if (lastValue != null) {
      subtitle =
          '${'measure_last'.tr()} ${numerals(_fmt(lastValue!), locale)} $unitLabel';
    } else {
      subtitle = '';
    }

    return GestureDetector(
      onTap: onFocus,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? AppColors.navy : AppColors.hairline,
            width: 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.10),
                    spreadRadius: 4,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(20, 40, 80, 0.04),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: value == null
                            ? AppColors.faintText
                            : AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepBtn(
                    icon: Icons.remove,
                    onTap: () => onChange(((value ?? 0) - step).clamp(0, 999)),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 58),
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: value == null
                                ? '—'
                                : numerals(_fmt(value!), locale),
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: value == null
                                  ? AppColors.faintText
                                  : AppColors.ink,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          TextSpan(
                            text: ' $unitLabel',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.faintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _StepBtn(
                    icon: Icons.add,
                    onTap: () => onChange(
                      (((value ?? 0) + step) * 100).roundToDouble() / 100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trims a trailing `.0` (40.0 → "40", 24.5 → "24.5").
  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 17, color: AppColors.navy),
        ),
      ),
    );
  }
}

// Save-as-template

class _SaveTemplateCard extends StatelessWidget {
  const _SaveTemplateCard({
    required this.checked,
    required this.garmentName,
    required this.onToggle,
  });

  final bool checked;
  final String garmentName;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? const Color(0xFFEEF2FA) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: checked ? AppColors.navy : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? AppColors.navy : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checked ? AppColors.navy : const Color(0xFFC2CAD6),
                    width: 2,
                  ),
                ),
                child: checked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.surface,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_border,
                          size: 15,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'measure_save_tpl'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'measure_save_tpl_sub'.tr(
                        namedArgs: {'garment': garmentName},
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

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
          onTap: onTap,
          child: SizedBox(
            height: 54,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
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

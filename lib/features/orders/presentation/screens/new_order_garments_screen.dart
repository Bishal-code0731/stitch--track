import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/utils/numerals.dart';
import '../../domain/entities/garment_template_entity.dart';
import '../providers/order_providers.dart';
import '../providers/order_wizard_provider.dart';
import '../widgets/garment_glyph.dart';
import '../widgets/order_wizard_header.dart';

class NewOrderGarmentsScreen extends ConsumerStatefulWidget {
  const NewOrderGarmentsScreen({super.key});

  @override
  ConsumerState<NewOrderGarmentsScreen> createState() =>
      _NewOrderGarmentsScreenState();
}

class _NewOrderGarmentsScreenState
    extends ConsumerState<NewOrderGarmentsScreen> {
  /// Line uids whose note field is expanded (transient UI state).
  final Set<int> _openNotes = {};

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final locale = localeFromCode(lang);
    final wizard = ref.watch(orderWizardProvider);
    final controller = ref.read(orderWizardProvider.notifier);
    final templatesAsync = ref.watch(activeGarmentTemplatesProvider);
    final templates = templatesAsync.value ?? const <GarmentTemplateEntity>[];
    final byId = {for (final t in templates) t.id: t};

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            OrderWizardHeader(
              stepIndex: 1,
              subtitle: 'neworder_step_of_garments'.tr(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    'garments_pick'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'garments_pick_sub'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  templatesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(child: Text('state_error_title'.tr())),
                    ),
                    data: (list) => _GarmentGrid(
                      templates: list,
                      lang: lang,
                      locale: locale,
                      countOf: wizard.quantityOfTemplate,
                      onAdd: controller.addGarment,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ThisOrderHeader(
                    lang: lang,
                    locale: locale,
                    lineCount: wizard.garments.length,
                    pieceCount: wizard.totalPieces,
                  ),
                  const SizedBox(height: 11),
                  if (wizard.garments.isEmpty)
                    const _EmptyOrder()
                  else
                    for (final g in wizard.garments) ...[
                      _GarmentLine(
                        template: byId[g.templateId],
                        quantity: g.quantity,
                        note: g.note,
                        noteOpen:
                            _openNotes.contains(g.uid) || g.note.isNotEmpty,
                        lang: lang,
                        locale: locale,
                        onInc: () =>
                            controller.setQuantity(g.uid, g.quantity + 1),
                        onDec: () =>
                            controller.setQuantity(g.uid, g.quantity - 1),
                        onRemove: () {
                          _openNotes.remove(g.uid);
                          controller.removeGarment(g.uid);
                        },
                        onOpenNote: () => setState(() => _openNotes.add(g.uid)),
                        onNote: (v) => controller.setNote(g.uid, v),
                      ),
                      if (g != wizard.garments.last) const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
            _Footer(
              enabled: wizard.garments.isNotEmpty,
              onContinue: () => context.push(Routes.newOrderMeasurements),
            ),
          ],
        ),
      ),
    );
  }
}

// Garment grid

class _GarmentGrid extends StatelessWidget {
  const _GarmentGrid({
    required this.templates,
    required this.lang,
    required this.locale,
    required this.countOf,
    required this.onAdd,
  });

  final List<GarmentTemplateEntity> templates;
  final String lang;
  final Locale locale;
  final int Function(String templateId) countOf;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: templates.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, i) {
        final t = templates[i];
        final count = countOf(t.id);
        return _GarmentTile(
          template: t,
          count: count,
          lang: lang,
          locale: locale,
          onTap: () => onAdd(t.id),
        );
      },
    );
  }
}

class _GarmentTile extends StatelessWidget {
  const _GarmentTile({
    required this.template,
    required this.count,
    required this.lang,
    required this.locale,
    required this.onTap,
  });

  final GarmentTemplateEntity template;
  final int count;
  final String lang;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = count > 0;
    return Material(
      color: on ? const Color(0xFFEEF2FA) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: on ? AppColors.navy : AppColors.hairline,
              width: 1.5,
            ),
            boxShadow: on
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(31, 56, 100, 0.10),
                      offset: Offset(0, 2),
                      blurRadius: 8,
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
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GarmentGlyph(
                    kind: garmentGlyphFor(template.nameEn),
                    size: 30,
                    color: on ? AppColors.navy : const Color(0xFF7C8699),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.name(lang),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: on ? AppColors.navy : AppColors.ink,
                    ),
                  ),
                ],
              ),
              if (on)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: Text(
                      numerals(count, locale),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.surface,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
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

// "This order" list

class _ThisOrderHeader extends StatelessWidget {
  const _ThisOrderHeader({
    required this.lang,
    required this.locale,
    required this.lineCount,
    required this.pieceCount,
  });

  final String lang;
  final Locale locale;
  final int lineCount;
  final int pieceCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'garments_this_order'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (lineCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              '${numerals(pieceCount, locale)} ${'garments_pcs'.tr()} · '
              '${numerals(lineCount, locale)} '
              '${(lineCount == 1 ? 'garments_item' : 'garments_items').tr()}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyOrder extends StatelessWidget {
  const _EmptyOrder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.hairline,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          GarmentGlyph(
            kind: GarmentKind.shirt,
            size: 36,
            color: AppColors.faintText.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'garments_empty'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'garments_empty_sub'.tr(),
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

class _GarmentLine extends StatelessWidget {
  const _GarmentLine({
    required this.template,
    required this.quantity,
    required this.note,
    required this.noteOpen,
    required this.lang,
    required this.locale,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
    required this.onOpenNote,
    required this.onNote,
  });

  final GarmentTemplateEntity? template;
  final int quantity;
  final String note;
  final bool noteOpen;
  final String lang;
  final Locale locale;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;
  final VoidCallback onOpenNote;
  final ValueChanged<String> onNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(20, 40, 80, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GarmentGlyph(
                  kind: garmentGlyphFor(template?.nameEn ?? ''),
                  size: 24,
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
                      template?.name(lang) ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: StatusColors.cutting.chipBackground,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 13,
                              color: StatusColors.cutting.chipText,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'garments_needs_measure'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: StatusColors.cutting.chipText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _QtyStepper(
                value: quantity,
                locale: locale,
                onInc: onInc,
                onDec: onDec,
              ),
              const SizedBox(width: 6),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F6FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 15,
                    color: AppColors.faintText,
                  ),
                ),
              ),
            ],
          ),
          if (noteOpen)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: 17,
                      color: AppColors.faintText,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _NoteField(note: note, onNote: onNote),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 11),
                child: InkWell(
                  onTap: onOpenNote,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 15, color: AppColors.navy),
                      const SizedBox(width: 6),
                      Text(
                        'garments_add_note'.tr(),
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
            ),
        ],
      ),
    );
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({required this.note, required this.onNote});

  final String note;
  final ValueChanged<String> onNote;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final TextEditingController _c = TextEditingController(
    text: widget.note,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      autofocus: widget.note.isEmpty,
      onChanged: widget.onNote,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.background,
        hintText: 'garments_note_ph'.tr(),
        hintStyle: const TextStyle(color: AppColors.faintText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.locale,
    required this.onInc,
    required this.onDec,
  });

  final int value;
  final Locale locale;
  final VoidCallback onInc;
  final VoidCallback onDec;

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
          _StepBtn(icon: Icons.remove, onTap: onDec),
          Container(
            constraints: const BoxConstraints(minWidth: 22),
            alignment: Alignment.center,
            child: Text(
              numerals(value, locale),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onInc),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: SizedBox(
          width: 31,
          height: 31,
          child: Icon(icon, size: 16, color: AppColors.navy),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.enabled, required this.onContinue});

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: enabled ? onContinue : null,
            child: SizedBox(
              height: 54,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'garments_continue'.tr(),
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
      ),
    );
  }
}

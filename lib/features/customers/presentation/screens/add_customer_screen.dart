import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/providers/active_branch_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/new_customer_request.dart';
import '../providers/customer_providers.dart';

final _branchNameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final branchId = ref.watch(activeBranchProvider);
  if (branchId == null) return null;
  final branch = await ref
      .watch(appDatabaseProvider)
      .branchDao
      .getById(branchId);
  if (branch == null) return null;
  return ref.watch(localeProvider).languageCode == 'ne'
      ? branch.nameNe
      : branch.nameEn;
});

/// Add New Customer form, built to `docs/design/stitchtrack_design_handoff/Add New Customer.html`.
class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController(text: '98');
  final _alt = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  Gender _gender = Gender.male;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _phone, _alt, _address, _notes]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _alt, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _phoneDigits => _phone.text.replaceAll(RegExp(r'\D'), '');
  bool get _valid => _name.text.trim().isNotEmpty && _phoneDigits.length == 10;

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    final customer = await ref
        .read(customerRepositoryProvider)
        .createCustomer(
          NewCustomerRequest(
            name: _name.text,
            phonePrimary: _phoneDigits,
            phoneAlternate: _alt.text,
            gender: _gender,
            address: _address.text,
            notes: _notes.text,
          ),
        );
    if (!mounted) return;
    context.pop<CustomerEntity>(customer);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final branchName = ref.watch(_branchNameProvider).value;

    // Phone validation state → hint.
    final ({_HintKind kind, String text}) phoneHint;
    _FieldState phoneState;
    if (_phoneDigits.isEmpty) {
      phoneState = _FieldState.normal;
      phoneHint = (
        kind: _HintKind.info,
        text: 'addcustomer_phone_required'.tr(),
      );
    } else if (_phoneDigits.length == 10) {
      phoneState = _FieldState.ok;
      phoneHint = (kind: _HintKind.ok, text: 'addcustomer_phone_ok'.tr());
    } else {
      phoneState = _FieldState.error;
      phoneHint = (kind: _HintKind.error, text: 'addcustomer_phone_bad'.tr());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _AppBar(
              subtitle: branchName == null
                  ? 'addcustomer_sub_generic'.tr()
                  : 'addcustomer_sub'.tr(namedArgs: {'branch': branchName}),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  const _AvatarPlaceholder(),
                  const SizedBox(height: 20),
                  _Label(
                    text: 'addcustomer_name'.tr(),
                    badge: 'addcustomer_badge_required'.tr(),
                    badgeTone: _BadgeTone.required,
                  ),
                  _Field(
                    controller: _name,
                    icon: Icons.person_outline,
                    placeholder: 'addcustomer_name_ph'.tr(),
                    state: _name.text.trim().isNotEmpty
                        ? _FieldState.ok
                        : _FieldState.normal,
                  ),
                  const SizedBox(height: 18),
                  _Label(
                    text: 'addcustomer_phone'.tr(),
                    badge: 'addcustomer_badge_primary'.tr(),
                    badgeTone: _BadgeTone.primary,
                  ),
                  _Field(
                    controller: _phone,
                    icon: Icons.call_outlined,
                    prefix: '+977',
                    placeholder: 'addcustomer_phone_ph'.tr(),
                    keyboardType: TextInputType.phone,
                    state: phoneState,
                  ),
                  _Hint(kind: phoneHint.kind, text: phoneHint.text),
                  const SizedBox(height: 18),
                  _Label(
                    text: 'addcustomer_alt_phone'.tr(),
                    badge: 'addcustomer_badge_optional'.tr(),
                  ),
                  _Field(
                    controller: _alt,
                    icon: Icons.phone_forwarded_outlined,
                    prefix: '+977',
                    placeholder: 'addcustomer_phone_ph'.tr(),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),
                  _Label(text: 'addcustomer_gender'.tr()),
                  _GenderPicker(
                    value: _gender,
                    onChanged: (g) => setState(() => _gender = g),
                  ),
                  const SizedBox(height: 8),
                  _InfoLine(text: 'addcustomer_gender_hint'.tr()),
                  const SizedBox(height: 18),
                  _Label(
                    text: 'addcustomer_address'.tr(),
                    badge: 'addcustomer_badge_optional'.tr(),
                  ),
                  _Field(
                    controller: _address,
                    icon: Icons.location_on_outlined,
                    placeholder: 'addcustomer_address_ph'.tr(),
                  ),
                  const SizedBox(height: 18),
                  _Label(
                    text: 'addcustomer_notes'.tr(),
                    badge: 'addcustomer_badge_optional'.tr(),
                  ),
                  _NotesField(controller: _notes),
                ],
              ),
            ),
            _Footer(
              enabled: _valid,
              saving: _saving,
              onSave: _save,
              lang: lang,
            ),
          ],
        ),
      ),
    );
  }
}

// App bar

class _AppBar extends ConsumerWidget {
  const _AppBar({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.paddingOf(context).top;
    final code = ref.watch(localeProvider).languageCode;
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: topPad + 8,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          _SquareIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'addcustomer_title'.tr(),
                  style: const TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
                Text(
                  subtitle,
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
          _LangToggle(code: code),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 19, color: AppColors.surface),
        ),
      ),
    );
  }
}

class _LangToggle extends ConsumerWidget {
  const _LangToggle({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
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
    );
  }
}

// Form pieces

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 78,
        height: 78,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECF4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBCC7DC), width: 2),
        ),
        child: const Icon(
          Icons.person_outline,
          size: 34,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

enum _BadgeTone { required, primary, optional }

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    this.badge,
    this.badgeTone = _BadgeTone.optional,
  });

  final String text;
  final String? badge;
  final _BadgeTone badgeTone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (badgeTone) {
      _BadgeTone.required => (
        StatusColors.overdue.chipBackground,
        StatusColors.overdue.color,
      ),
      _BadgeTone.primary => (const Color(0xFFE8ECF4), AppColors.navy),
      _BadgeTone.optional => (const Color(0xFFEEF1F6), AppColors.mutedText),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                badge!.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: fg,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _FieldState { normal, ok, error }

class _Field extends StatefulWidget {
  const _Field({
    required this.controller,
    this.icon,
    this.prefix,
    this.placeholder,
    this.keyboardType,
    this.state = _FieldState.normal,
  });

  final TextEditingController controller;
  final IconData? icon;
  final String? prefix;
  final String? placeholder;
  final TextInputType? keyboardType;
  final _FieldState state;

  @override
  State<_Field> createState() => _FieldStateWidget();
}

class _FieldStateWidget extends State<_Field> {
  final _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (_focused != _node.hasFocus) setState(() => _focused = _node.hasFocus);
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color border = switch (widget.state) {
      _FieldState.error => StatusColors.overdue.color,
      _FieldState.ok => StatusColors.ready.color,
      _FieldState.normal => _focused ? AppColors.navy : AppColors.hairline,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border, width: 1.5),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: border.withValues(alpha: 0.13),
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
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 19,
              color: _focused ? AppColors.navy : AppColors.faintText,
            ),
            const SizedBox(width: 10),
          ],
          if (widget.prefix != null) ...[
            Text(
              widget.prefix!,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _node,
              keyboardType: widget.keyboardType,
              style: const TextStyle(fontSize: 16, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: AppColors.faintText),
              ),
            ),
          ),
          if (widget.state == _FieldState.ok)
            Icon(Icons.check, size: 18, color: StatusColors.ready.color),
        ],
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.hairline, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: 19,
              color: AppColors.faintText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 15.5, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'addcustomer_notes_ph'.tr(),
                hintStyle: const TextStyle(color: AppColors.faintText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _HintKind { info, ok, error }

class _Hint extends StatelessWidget {
  const _Hint({required this.kind, required this.text});

  final _HintKind kind;
  final String text;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (kind) {
      _HintKind.error => (
        StatusColors.overdue.color,
        Icons.warning_amber_rounded,
      ),
      _HintKind.ok => (StatusColors.ready.color, Icons.check),
      _HintKind.info => (AppColors.mutedText, Icons.info_outline),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 14, color: AppColors.faintText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.faintText,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});

  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (Gender.male, Icons.male, 'addcustomer_gender_male'.tr()),
      (Gender.female, Icons.female, 'addcustomer_gender_female'.tr()),
      (Gender.other, Icons.circle_outlined, 'addcustomer_gender_other'.tr()),
    ];
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: _GenderOption(
              icon: options[i].$2,
              label: options[i].$3,
              selected: value == options[i].$1,
              onTap: () => onChanged(options[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
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
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.hairline,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.navy : AppColors.mutedText,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
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

class _Footer extends StatelessWidget {
  const _Footer({
    required this.enabled,
    required this.saving,
    required this.onSave,
    required this.lang,
  });

  final bool enabled;
  final bool saving;
  final VoidCallback onSave;
  final String lang;

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
            onTap: enabled && !saving ? onSave : null,
            child: SizedBox(
              height: 54,
              child: Center(
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.surface,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'addcustomer_save'.tr(),
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

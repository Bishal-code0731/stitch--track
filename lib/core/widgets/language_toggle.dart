import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/locale_provider.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({
    this.light = false,
    this.fullNepaliLabel = false,
    super.key,
  });

  final bool light;

  /// Shows the Nepali segment as the full word "नेपाली" instead of the short "ने".
  final bool fullNepaliLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;

    return Semantics(
      label: 'language'.tr(),
      container: true,
      child: Container(
        margin: light
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 6),
        padding: light ? const EdgeInsets.all(3) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: light ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: light
                ? AppColors.hairline
                : AppColors.surface.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment(
              ref,
              label: 'EN',
              selected: code == 'en',
              locale: localeEn,
            ),
            _segment(
              ref,
              label: fullNepaliLabel ? 'नेपाली' : 'ने',
              selected: code == 'ne',
              locale: localeNe,
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    WidgetRef ref, {
    required String label,
    required bool selected,
    required Locale locale,
  }) {
    final selectedBg = light ? AppColors.navy : AppColors.amber;
    final selectedFg = light ? AppColors.surface : AppColors.ink;
    final unselectedFg = light ? AppColors.mutedText : AppColors.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: selected
          ? null
          : () => ref.read(localeProvider.notifier).setLocale(locale),
      child: Container(
        constraints: BoxConstraints(
          minWidth: light ? 0 : 44,
          minHeight: light ? 0 : 32,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? selectedFg : unselectedFg,
          ),
        ),
      ),
    );
  }
}

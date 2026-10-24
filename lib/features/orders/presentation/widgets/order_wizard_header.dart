import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/theme/colors.dart';
import 'order_wizard_stepper.dart';

class OrderWizardHeader extends ConsumerWidget {
  const OrderWizardHeader({
    required this.stepIndex,
    required this.subtitle,
    this.bottom,
    super.key,
  });

  final int stepIndex;
  final String subtitle;

  /// Optional widget rendered inside the navy header below the stepper (e.g.
  final Widget? bottom;

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
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, bottom == null ? 16 : 14),
            child: OrderWizardStepper(activeIndex: stepIndex),
          ),
          if (bottom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: bottom!,
            ),
        ],
      ),
    );
  }
}

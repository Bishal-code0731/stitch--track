import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  String? _toast;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _choose(Locale locale, String toastText) {
    ref.read(localeProvider.notifier).setLocale(locale);
    _toastTimer?.cancel();
    setState(() => _toast = toastText);
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyDark.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _TopBarIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: _leave,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'auth_language_settings_title'.tr(),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                      const _TopBarIconButton(icon: Icons.public),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    Text(
                      'auth_language_pick_title'.tr(),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'auth_language_pick_sub'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LangCard(
                      glyph: 'A',
                      title: 'language_english'.tr(),
                      subtitle: 'English (US)',
                      selected: locale.languageCode == 'en',
                      onTap: () => _choose(localeEn, 'Language set to English'),
                      preview: const _PreviewCard(
                        id: 'TS-1042',
                        name: 'Ramesh Shrestha',
                        initials: 'RS',
                        garment: 'Daura Suruwal +1',
                        status: 'In production',
                        stage: 'Stitching',
                        deliveryLabel: 'Delivery',
                        delivery: '12 Jun',
                        balanceLabel: 'Balance',
                        balance: 'Rs 4,500',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x14),
                    _LangCard(
                      glyph: 'अ',
                      title: 'language_nepali'.tr(),
                      subtitle: 'Nepali · Devanagari',
                      selected: locale.languageCode == 'ne',
                      onTap: () => _choose(localeNe, 'भाषा नेपालीमा सेट भयो'),
                      preview: const _PreviewCard(
                        id: 'TS-1042',
                        name: 'रमेश श्रेष्ठ',
                        initials: 'RS',
                        garment: 'दौरा सुरुवाल +१',
                        status: 'उत्पादनमा',
                        stage: 'सिलाई',
                        deliveryLabel: 'डेलिभरी',
                        delivery: '१२ जुन',
                        balanceLabel: 'बाँकी',
                        balance: 'रू ४,५००',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        border: Border.all(color: const Color(0xFFDCE4F2)),
                        borderRadius: BorderRadius.circular(AppRadii.card - 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 19,
                            color: AppColors.navy,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'auth_language_note'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF34507E),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.hairline)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _leave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadii.largeCard - 5,
                          ),
                        ),
                      ),
                      child: Text(
                        'auth_language_done'.tr(),
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_toast != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 96,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppRadii.card - 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 20,
                        color: Color(0xFF4FE08A),
                      ),
                      const SizedBox(width: 11),
                      Flexible(
                        child: Text(
                          _toast!,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.surface,
                          ),
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

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.iconTile),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.iconTile),
        ),
        child: Icon(icon, size: 20, color: AppColors.surface),
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.preview,
  });

  final String glyph;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFBFCFE) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.largeCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.largeCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.largeCard),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.hairline,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.navy
                          : const Color(0xFFEEF1F6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      glyph,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: selected ? AppColors.surface : AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    scale: selected ? 1 : 0.001,
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              preview,
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.id,
    required this.name,
    required this.initials,
    required this.garment,
    required this.status,
    required this.stage,
    required this.deliveryLabel,
    required this.delivery,
    required this.balanceLabel,
    required this.balance,
  });

  final String id;
  final String name;
  final String initials;
  final String garment;
  final String status;
  final String stage;
  final String deliveryLabel;
  final String delivery;
  final String balanceLabel;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$id',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bolt, size: 13, color: AppColors.amber),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: StatusColors.cutting.chipBackground,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StatusColors.cutting.color,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: StatusColors.cutting.chipText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StatusColors.cutting.color.withValues(alpha: 0.1),
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: StatusColors.cutting.color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          size: 13,
                          color: AppColors.navy,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            garment,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
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
                children: [
                  Text(
                    balanceLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.faintText,
                    ),
                  ),
                  Text(
                    balance,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFEEF1F6)),
                  FractionallySizedBox(
                    widthFactor: 0.52,
                    child: Container(color: StatusColors.cutting.color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stage,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$deliveryLabel · $delivery',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

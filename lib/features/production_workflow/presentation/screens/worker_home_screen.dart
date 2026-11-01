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
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../demo/worker_home_demo.dart';

class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

/// The queue filter: all jobs, a single stage, or overdue-only.
enum _WorkerFilter { all, cutting, stitching, trial, overdue }

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  _WorkerFilter _filter = _WorkerFilter.all;

  int _stageCount(WorkerStage stage) =>
      demoWorkerJobs.where((j) => j.stage == stage).length;

  int get _overdueCount => demoWorkerJobs.where((j) => j.overdue).length;

  List<WorkerJob> get _visibleJobs {
    Iterable<WorkerJob> list = demoWorkerJobs;
    switch (_filter) {
      case _WorkerFilter.all:
        break;
      case _WorkerFilter.overdue:
        list = list.where((j) => j.overdue);
      case _WorkerFilter.cutting:
        list = list.where((j) => j.stage == WorkerStage.cutting);
      case _WorkerFilter.stitching:
        list = list.where((j) => j.stage == WorkerStage.stitching);
      case _WorkerFilter.trial:
        list = list.where((j) => j.stage == WorkerStage.trial);
    }
    // Overdue first, then priority — same ordering as the mockup.
    final sorted = list.toList()
      ..sort((a, b) {
        final byOverdue = (b.overdue ? 1 : 0) - (a.overdue ? 1 : 0);
        if (byOverdue != 0) return byOverdue;
        return (b.priority ? 1 : 0) - (a.priority ? 1 : 0);
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final lang = locale.languageCode;
    final user = ref.watch(authSessionProvider).value;
    final name = user?.name ?? 'Hari';
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final initials = user == null ? 'HM' : AppAvatar.initialsOf(name);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            _Header(greetingName: firstName, initials: initials, lang: lang),
            _QueueHeader(lang: lang, locale: locale),
            _FilterChips(
              filter: _filter,
              lang: lang,
              locale: locale,
              allCount: demoWorkerJobs.length,
              cuttingCount: _stageCount(WorkerStage.cutting),
              stitchingCount: _stageCount(WorkerStage.stitching),
              trialCount: _stageCount(WorkerStage.trial),
              overdueCount: _overdueCount,
              onSelect: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: _JobList(jobs: _visibleJobs, lang: lang),
            ),
          ],
        ),
      ),
    );
  }
}

// Header (identity + language toggle + scan CTA)

class _Header extends StatelessWidget {
  const _Header({
    required this.greetingName,
    required this.initials,
    required this.lang,
  });

  final String greetingName;
  final String initials;
  final String lang;

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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                _Avatar(initials: initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'worker_home_greeting'.tr(
                          namedArgs: {'name': greetingName},
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        demoWorkerBranch.resolve(lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.surface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const _LangButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: _ScanButton(lang: lang),
          ),
        ],
      ),
    );
  }
}

/// Header identity avatar.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'auth_account_title'.tr(),
      button: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.push(Routes.account),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withValues(alpha: 0.16),
          ),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Globe + EN/ने single-button language toggle, matching the mockup (and the other role headers).
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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

/// The navy gradient "Scan barcode" CTA.
class _ScanButton extends StatefulWidget {
  const _ScanButton({required this.lang});

  final String lang;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  bool _scanning = false;

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  void _scan() {
    if (_scanning) return;
    setState(() => _scanning = true);
    _line.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _line
        ..stop()
        ..reset();
      setState(() => _scanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _scan,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF26467F), AppColors.navyDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(31, 56, 100, 0.32),
                offset: Offset(0, 10),
                blurRadius: 26,
              ),
            ],
          ),
          child: Row(
            children: [
              _ScanIconTile(scanning: _scanning, line: _line),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (_scanning ? 'worker_home_scanning' : 'worker_home_scan')
                          .tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'worker_home_scan_sub'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.surface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.surface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanIconTile extends StatelessWidget {
  const _ScanIconTile({required this.scanning, required this.line});

  final bool scanning;
  final AnimationController line;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(17),
      ),
      child: scanning
          ? Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.navyDark,
                    ),
                  ),
                ),
                // Sweeping scanline, top 8% → 88% of the tile.
                AnimatedBuilder(
                  animation: line,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(line.value);
                    return Positioned(
                      left: 6,
                      right: 6,
                      top: 60 * (0.08 + 0.80 * t),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.navyDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : const Icon(
              Icons.photo_camera_outlined,
              size: 32,
              color: AppColors.navyDark,
            ),
    );
  }
}

// Queue header + filter chips

class _QueueHeader extends StatelessWidget {
  const _QueueHeader({required this.lang, required this.locale});

  final String lang;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'worker_home_queue'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Text(
              '${numerals(demoWorkerJobs.length, locale)} '
              '${'worker_home_jobs'.tr()}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.lang,
    required this.locale,
    required this.allCount,
    required this.cuttingCount,
    required this.stitchingCount,
    required this.trialCount,
    required this.overdueCount,
    required this.onSelect,
  });

  final _WorkerFilter filter;
  final String lang;
  final Locale locale;
  final int allCount;
  final int cuttingCount;
  final int stitchingCount;
  final int trialCount;
  final int overdueCount;
  final ValueChanged<_WorkerFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _Chip(
        label: 'worker_home_all'.tr(),
        count: allCount,
        selected: filter == _WorkerFilter.all,
        locale: locale,
        onTap: () => onSelect(_WorkerFilter.all),
      ),
      _Chip(
        label: WorkerStage.cutting.labelKey.tr(),
        count: cuttingCount,
        selected: filter == _WorkerFilter.cutting,
        locale: locale,
        onTap: () => onSelect(_WorkerFilter.cutting),
      ),
      _Chip(
        label: WorkerStage.stitching.labelKey.tr(),
        count: stitchingCount,
        selected: filter == _WorkerFilter.stitching,
        locale: locale,
        onTap: () => onSelect(_WorkerFilter.stitching),
      ),
      _Chip(
        label: WorkerStage.trial.labelKey.tr(),
        count: trialCount,
        selected: filter == _WorkerFilter.trial,
        locale: locale,
        onTap: () => onSelect(_WorkerFilter.trial),
      ),
      _Chip(
        label: 'worker_home_overdue'.tr(),
        count: overdueCount,
        selected: filter == _WorkerFilter.overdue,
        danger: true,
        locale: locale,
        onTap: () => onSelect(_WorkerFilter.overdue),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.locale,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final int count;
  final bool selected;
  final bool danger;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final red = StatusColors.overdue.color;
    final dangerOn = danger && count > 0;

    final Color bg;
    final Color fg;
    final Color border;
    if (selected) {
      bg = danger ? red : AppColors.navy;
      fg = AppColors.surface;
      border = danger ? red : AppColors.navy;
    } else {
      bg = AppColors.surface;
      fg = dangerOn ? red : AppColors.mutedText;
      border = dangerOn ? const Color(0xFFF3C6C2) : AppColors.hairline;
    }

    // Count badge tones.
    final Color badgeBg;
    final Color badgeFg;
    if (selected) {
      badgeBg = AppColors.surface.withValues(alpha: 0.25);
      badgeFg = AppColors.surface;
    } else if (dangerOn) {
      badgeBg = StatusColors.overdue.chipBackground;
      badgeFg = red;
    } else {
      badgeBg = const Color(0xFFEEF1F6);
      badgeFg = AppColors.mutedText;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  numerals(count, locale),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: badgeFg,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

// Job list

class _JobList extends StatelessWidget {
  const _JobList({required this.jobs, required this.lang});

  final List<WorkerJob> jobs;
  final String lang;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_box_outlined,
              size: 42,
              color: AppColors.faintText.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              'worker_home_none'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 11),
      itemBuilder: (context, i) => _JobCard(job: jobs[i], lang: lang),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.lang});

  final WorkerJob job;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final stage = job.stage.colors;
    final accent = job.overdue
        ? StatusColors.overdue.color
        : job.priority
        ? AppColors.amber
        : stage.color;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () {},
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.hairline),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(20, 40, 80, 0.05),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopRow(job: job, stage: stage, lang: lang),
                        const SizedBox(height: 12),
                        _BottomRow(job: job, stage: stage, lang: lang),
                      ],
                    ),
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

class _TopRow extends StatelessWidget {
  const _TopRow({required this.job, required this.stage, required this.lang});

  final WorkerJob job;
  final StatusColor stage;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: stage.chipBackground,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.sell_outlined, size: 23, color: stage.chipText),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      job.garment.resolve(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (job.priority && !job.overdue) ...[
                    const SizedBox(width: 7),
                    const Icon(Icons.bolt, size: 15, color: AppColors.amber),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                '#${job.order} · ${job.customer.resolve(lang)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 20, color: Color(0xFFC2CAD6)),
      ],
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.job,
    required this.stage,
    required this.lang,
  });

  final WorkerJob job;
  final StatusColor stage;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stage pill (dot + label).
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: stage.chipBackground,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: stage.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                job.stage.labelKey.tr(),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: stage.chipText,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (job.overdue)
          _OverduePill(lang: lang)
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 15, color: AppColors.mutedText),
              const SizedBox(width: 5),
              Text(
                '${'worker_home_due'.tr()} ${job.due.resolve(lang)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// The pulsing red "Overdue" pill from the mockup (clock icon + label).
class _OverduePill extends StatefulWidget {
  const _OverduePill({required this.lang});

  final String lang;

  @override
  State<_OverduePill> createState() => _OverduePillState();
}

class _OverduePillState extends State<_OverduePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final red = StatusColors.overdue.color;
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: 0.55,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: StatusColors.overdue.chipBackground,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 14, color: red),
            const SizedBox(width: 5),
            Text(
              'worker_home_overdue'.tr(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

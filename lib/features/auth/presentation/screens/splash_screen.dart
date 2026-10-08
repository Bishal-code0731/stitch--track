import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/indeterminate_loader_bar.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _entranceCurve = Cubic(0.2, 0.7, 0.2, 1);
  static const _minDisplay = Duration(milliseconds: 900);

  late final AnimationController _controller;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) return;
    _animationStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = Duration.zero;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    final stopwatch = Stopwatch()..start();
    final user = await ref
        .read(authSessionProvider.future)
        .catchError((_) => null);
    final elapsed = stopwatch.elapsed;
    if (elapsed < _minDisplay) {
      await Future<void>.delayed(_minDisplay - elapsed);
    }
    if (!mounted) return;
    context.go(user != null ? Routes.welcome : Routes.login);
  }

  Animation<double> _staggered(double startFraction) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(startFraction, 1.0, curve: _entranceCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [AppColors.navy, AppColors.navyDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EntranceScale(
                        animation: _staggered(0),
                        child: const _LogoMark(),
                      ),
                      const SizedBox(height: 26),
                      _EntranceRise(
                        animation: _staggered(0.25),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Stitch',
                                style: TextStyle(color: AppColors.surface),
                              ),
                              TextSpan(
                                text: 'Track',
                                style: TextStyle(color: AppColors.amber),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _EntranceRise(
                        animation: _staggered(0.42),
                        child: Text(
                          'Every order, tracked.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.surface.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _EntranceRise(
                        animation: _staggered(0.54),
                        child: Text(
                          'हरेक अर्डर, ट्र्याकमा।',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.surface.withValues(alpha: 0.46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _EntranceRise(
                animation: _staggered(0.7),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    children: [
                      const IndeterminateLoaderBar(),
                      const SizedBox(height: 16),
                      Text(
                        'splash_footer'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.surface.withValues(alpha: 0.32),
                        ),
                      ),
                    ],
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

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.16),
                width: 1.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.04),
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.08),
              ),
            ),
          ),
          SvgPicture.asset('assets/branding/logo.svg', width: 84, height: 84),
        ],
      ),
    );
  }
}

/// Scale-in + fade, matching the design's `.splash-logo` entrance.
class _EntranceScale extends StatelessWidget {
  const _EntranceScale({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0, 1),
        child: Transform.scale(
          scale: 0.82 + (0.18 * animation.value),
          child: child,
        ),
      ),
    );
  }
}

/// Rise (translateY) + fade, matching the design's `.splash-rise-in` group.
class _EntranceRise extends StatelessWidget {
  const _EntranceRise({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

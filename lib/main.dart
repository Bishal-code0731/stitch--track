import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/database/seed_data.dart';
import 'core/i18n/locale_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  await seedDatabase(container.read(appDatabaseProvider));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: supportedLocales,
        path: i18nAssetPath,
        fallbackLocale: fallbackLocale,
        startLocale: localeFromCode(prefs.getString(localePrefsKey)),
        saveLocale: false, // Riverpod + shared_preferences owns persistence.
        child: const StitchTrackApp(),
      ),
    ),
  );
}

/// Root app widget.
class StitchTrackApp extends ConsumerStatefulWidget {
  const StitchTrackApp({super.key});

  @override
  ConsumerState<StitchTrackApp> createState() => _StitchTrackAppState();
}

class _StitchTrackAppState extends ConsumerState<StitchTrackApp> {
  GoRouter? _router;
  String? _routerLocale;

  late final AuthRefreshListenable _authRefresh = AuthRefreshListenable(ref);

  @override
  void dispose() {
    _authRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Locale>(localeProvider, (_, next) {
      if (context.locale != next) context.setLocale(next);
    });

    // Rebuild the GoRouter whenever the language actually changes.
    final localeCode = context.locale.languageCode;
    if (_router == null || _routerLocale != localeCode) {
      _router = buildAppRouter(ref: ref, refresh: _authRefresh);
      _routerLocale = localeCode;
    }

    return MaterialApp.router(
      title: 'StitchTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: _router,
      builder: (context, child) =>
          _ResponsiveFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Keeps the phone-first UI looking intentional on any screen size.
class _ResponsiveFrame extends StatelessWidget {
  const _ResponsiveFrame({required this.child});

  final Widget child;

  /// ~1.5× a typical phone logical width — roomy on large phones, still phone-shaped on desktop.
  static const double _maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= _maxContentWidth) return child;
    return ColoredBox(
      color: const Color(0xFFE2E7F0),
      child: Center(
        child: ClipRect(
          child: SizedBox(width: _maxContentWidth, child: child),
        ),
      ),
    );
  }
}

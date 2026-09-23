import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app locales (see `docs/03-design-system.md` — bilingual en/ne).
const Locale localeEn = Locale('en');
const Locale localeNe = Locale('ne');
const List<Locale> supportedLocales = [localeEn, localeNe];
const Locale fallbackLocale = localeEn;

/// Path (relative to assets) holding `en.json` / `ne.json` for easy_localization.
const String i18nAssetPath = 'assets/i18n';

/// `shared_preferences` key the chosen locale persists under.
const String localePrefsKey = 'app_locale';

/// Maps a stored language code to a [Locale], defaulting to English.
Locale localeFromCode(String? code) => code == 'ne' ? localeNe : localeEn;

/// Holds the [SharedPreferences] instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the '
    'resolved SharedPreferences instance.',
  );
});

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return localeFromCode(prefs.getString(localePrefsKey));
  }

  /// Sets and persists the locale.
  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(localePrefsKey, locale.languageCode);
  }

  /// Toggles between the two supported locales.
  Future<void> toggle() =>
      setLocale(state.languageCode == 'en' ? localeNe : localeEn);
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

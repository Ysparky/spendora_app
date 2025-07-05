import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  Locale? _locale;

  LocaleProvider(this._prefs) {
    // Load saved locale or default to system locale
    final String? savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      _locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
    }
  }

  Locale? get locale => _locale;

  // Get list of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
  ];

  // Get list of supported languages for UI
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
  ];

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    await _prefs.setString(_localeKey, locale.toString());
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    await _prefs.remove(_localeKey);
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'code': languageCode, 'name': languageCode},
    );
    return language['name']!;
  }
}

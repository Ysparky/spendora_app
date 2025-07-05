import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _themeKey = 'theme_is_dark';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_hasCompletedOnboardingKey) ?? false;

  Future<void> setHasCompletedOnboarding(bool value) =>
      _prefs.setBool(_hasCompletedOnboardingKey, value);

  Future<void> clearAll() => _prefs.clear();

  // Theme
  bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_themeKey, isDark);
  }
}

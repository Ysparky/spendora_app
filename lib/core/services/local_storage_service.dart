import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Currency display mode for multi-currency transactions
enum CurrencyDisplayMode {
  unified, // Convert all to user's preferred currency
  grouped, // Group by currency
}

class LocalStorageService extends ChangeNotifier {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _themeKey = 'theme_is_dark';
  static const String _currencyDisplayModeKey = 'currency_display_mode';

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
    notifyListeners();
  }

  // Currency Display Mode
  CurrencyDisplayMode get currencyDisplayMode {
    final value = _prefs.getString(_currencyDisplayModeKey);
    return value == CurrencyDisplayMode.unified.name
        ? CurrencyDisplayMode.unified
        : CurrencyDisplayMode.grouped;
  }

  Future<void> setCurrencyDisplayMode(CurrencyDisplayMode mode) async {
    await _prefs.setString(_currencyDisplayModeKey, mode.name);
    notifyListeners();
  }
}

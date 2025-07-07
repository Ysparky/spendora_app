import 'package:flutter/material.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

extension LocaleUtils on BuildContext {
  /// Gets the current locale code (e.g., 'en', 'es')
  String get currentLocaleCode =>
      AppLocalizations.of(this)?.localeName.split('_')[0] ?? 'en';
}

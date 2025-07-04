import 'package:flutter/material.dart';
import 'package:spendora_app/core/theme/color_schemes.dart';
import 'package:spendora_app/core/theme/text_theme.dart';

/// App theme configuration
class AppTheme {
  const AppTheme._();

  /// Light theme
  static ThemeData light(BuildContext context) {
    return _theme(context, AppColorScheme.lightScheme());
  }

  /// Dark theme
  static ThemeData dark(BuildContext context) {
    return _theme(context, AppColorScheme.darkScheme());
  }

  static ThemeData _theme(BuildContext context, ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme:
          AppTextTheme.create(
            context,
            'Inter', // Body font
            'Poppins', // Display font
          ).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text theme configuration
class AppTextTheme {
  const AppTextTheme._();

  /// Create text theme with custom body and display fonts
  static TextTheme create(
    BuildContext context,
    String bodyFontString,
    String displayFontString,
  ) {
    TextTheme baseTextTheme = Theme.of(context).textTheme;
    TextTheme bodyTextTheme = GoogleFonts.getTextTheme(
      bodyFontString,
      baseTextTheme,
    );
    TextTheme displayTextTheme = GoogleFonts.getTextTheme(
      displayFontString,
      baseTextTheme,
    );

    return displayTextTheme.copyWith(
      bodyLarge: bodyTextTheme.bodyLarge,
      bodyMedium: bodyTextTheme.bodyMedium,
      bodySmall: bodyTextTheme.bodySmall,
      labelLarge: bodyTextTheme.labelLarge,
      labelMedium: bodyTextTheme.labelMedium,
      labelSmall: bodyTextTheme.labelSmall,
    );
  }
}

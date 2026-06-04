import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
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
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme.copyWith(
    displayLarge: _compactTextStyle(textTheme.displayLarge, 52, 1.08),
    displayMedium: _compactTextStyle(textTheme.displayMedium, 40, 1.12),
    displaySmall: _compactTextStyle(textTheme.displaySmall, 32, 1.16),
    headlineLarge: _compactTextStyle(textTheme.headlineLarge, 29, 1.18),
    headlineMedium: _compactTextStyle(textTheme.headlineMedium, 25, 1.2),
    headlineSmall: _compactTextStyle(textTheme.headlineSmall, 22, 1.22),
    titleLarge: _compactTextStyle(textTheme.titleLarge, 20, 1.24),
    titleMedium: _compactTextStyle(textTheme.titleMedium, 15, 1.3),
    titleSmall: _compactTextStyle(textTheme.titleSmall, 13, 1.32),
    bodyLarge: _compactTextStyle(textTheme.bodyLarge, 15, 1.42),
    bodyMedium: _compactTextStyle(textTheme.bodyMedium, 13.5, 1.4),
    bodySmall: _compactTextStyle(textTheme.bodySmall, 12, 1.36),
    labelLarge: _compactTextStyle(textTheme.labelLarge, 13, 1.24),
    labelMedium: _compactTextStyle(textTheme.labelMedium, 11.5, 1.2),
    labelSmall: _compactTextStyle(textTheme.labelSmall, 10.5, 1.18),
  );
}

TextStyle? _compactTextStyle(TextStyle? style, double fontSize, double height) {
  return style?.copyWith(fontSize: fontSize, height: height);
}

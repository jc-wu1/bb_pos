import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static const Color _racingRed = Color(0xffc9181f);
  static const Color _deepRed = Color(0xff93000a);
  static const Color _speedOrange = Color(0xff9a4d00);
  static const Color _noodleGold = Color(0xff725c00);
  static const Color _ink = Color(0xff211a17);

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: _racingRed,
      brightness: Brightness.light,
    ).copyWith(
      primary: _racingRed,
      surfaceTint: _racingRed,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xffffdad6),
      onPrimaryContainer: const Color(0xff410002),
      secondary: _speedOrange,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xffffdcc2),
      onSecondaryContainer: const Color(0xff301400),
      tertiary: _noodleGold,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xffffe16a),
      onTertiaryContainer: const Color(0xff241a00),
      error: const Color(0xffba1a1a),
      onError: Colors.white,
      errorContainer: const Color(0xffffdad6),
      onErrorContainer: const Color(0xff410002),
      surface: const Color(0xfffff8f4),
      onSurface: _ink,
      onSurfaceVariant: const Color(0xff57433d),
      outline: const Color(0xff88736a),
      outlineVariant: const Color(0xffdec2b7),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xff382e2a),
      inversePrimary: const Color(0xffffb4ab),
      primaryFixed: const Color(0xffffdad6),
      onPrimaryFixed: const Color(0xff410002),
      primaryFixedDim: const Color(0xffffb4ab),
      onPrimaryFixedVariant: _deepRed,
      secondaryFixed: const Color(0xffffdcc2),
      onSecondaryFixed: const Color(0xff301400),
      secondaryFixedDim: const Color(0xffffb77c),
      onSecondaryFixedVariant: const Color(0xff6f3600),
      tertiaryFixed: const Color(0xffffe16a),
      onTertiaryFixed: const Color(0xff241a00),
      tertiaryFixedDim: const Color(0xffe7c448),
      onTertiaryFixedVariant: const Color(0xff574500),
      surfaceDim: const Color(0xffe8d7cf),
      surfaceBright: const Color(0xfffff8f4),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xfffff1e8),
      surfaceContainer: const Color(0xfffbe9df),
      surfaceContainerHigh: const Color(0xfff5e3d9),
      surfaceContainerHighest: const Color(0xffefddd3),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return lightScheme().copyWith(
      primary: const Color(0xff760006),
      surfaceTint: const Color(0xff760006),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xffd02a30),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xff552700),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xffb35b00),
      onSecondaryContainer: Colors.white,
      tertiary: const Color(0xff423300),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xff856c00),
      onTertiaryContainer: Colors.white,
      error: const Color(0xff740006),
      errorContainer: const Color(0xffcf2c27),
      onErrorContainer: Colors.white,
      onSurface: const Color(0xff17100e),
      onSurfaceVariant: const Color(0xff44302a),
      outline: const Color(0xff624d45),
      outlineVariant: const Color(0xff806a61),
      surfaceDim: const Color(0xffd3c3bb),
      surfaceContainer: const Color(0xffeddbd1),
      surfaceContainerHigh: const Color(0xffe1d0c7),
      surfaceContainerHighest: const Color(0xffd6c5bd),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return lightScheme().copyWith(
      primary: const Color(0xff3f0002),
      surfaceTint: const Color(0xff3f0002),
      onPrimary: Colors.white,
      primaryContainer: _deepRed,
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xff351800),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xff6f3600),
      onSecondaryContainer: Colors.white,
      tertiary: const Color(0xff2b2100),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xff574500),
      onTertiaryContainer: Colors.white,
      error: const Color(0xff600004),
      errorContainer: const Color(0xff98000a),
      onErrorContainer: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.black,
      outline: const Color(0xff251713),
      outlineVariant: const Color(0xff44302a),
      surfaceDim: const Color(0xffc5b5ad),
      surfaceContainer: const Color(0xffe3d2c9),
      surfaceContainerHigh: const Color(0xffd6c5bd),
      surfaceContainerHighest: const Color(0xffcabab2),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: _racingRed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xffffb4ab),
      surfaceTint: const Color(0xffffb4ab),
      onPrimary: const Color(0xff690005),
      primaryContainer: _deepRed,
      onPrimaryContainer: const Color(0xffffdad6),
      secondary: const Color(0xffffb77c),
      onSecondary: const Color(0xff512500),
      secondaryContainer: const Color(0xff713700),
      onSecondaryContainer: const Color(0xffffdcc2),
      tertiary: const Color(0xffe7c448),
      onTertiary: const Color(0xff3d3000),
      tertiaryContainer: const Color(0xff574500),
      onTertiaryContainer: const Color(0xffffe16a),
      error: const Color(0xffffb4ab),
      onError: const Color(0xff690005),
      errorContainer: _deepRed,
      onErrorContainer: const Color(0xffffdad6),
      surface: const Color(0xff211915),
      onSurface: const Color(0xfff4ded6),
      onSurfaceVariant: const Color(0xffdec2b7),
      outline: const Color(0xffa98c82),
      outlineVariant: const Color(0xff57433d),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xfff4ded6),
      inversePrimary: _racingRed,
      primaryFixed: const Color(0xffffdad6),
      onPrimaryFixed: const Color(0xff410002),
      primaryFixedDim: const Color(0xffffb4ab),
      onPrimaryFixedVariant: _deepRed,
      secondaryFixed: const Color(0xffffdcc2),
      onSecondaryFixed: const Color(0xff301400),
      secondaryFixedDim: const Color(0xffffb77c),
      onSecondaryFixedVariant: const Color(0xff713700),
      tertiaryFixed: const Color(0xffffe16a),
      onTertiaryFixed: const Color(0xff241a00),
      tertiaryFixedDim: const Color(0xffe7c448),
      onTertiaryFixedVariant: const Color(0xff574500),
      surfaceDim: const Color(0xff211915),
      surfaceBright: const Color(0xff4a3a33),
      surfaceContainerLowest: const Color(0xff18110f),
      surfaceContainerLow: const Color(0xff2b211d),
      surfaceContainer: const Color(0xff302621),
      surfaceContainerHigh: const Color(0xff3b302a),
      surfaceContainerHighest: const Color(0xff473a33),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return darkScheme().copyWith(
      primary: const Color(0xffffdad6),
      surfaceTint: const Color(0xffffdad6),
      onPrimary: const Color(0xff540003),
      primaryContainer: const Color(0xffff8f86),
      onPrimaryContainer: Colors.black,
      secondary: const Color(0xffffdcc2),
      onSecondary: const Color(0xff3d1b00),
      secondaryContainer: const Color(0xffffa65f),
      onSecondaryContainer: Colors.black,
      tertiary: const Color(0xffffe16a),
      onTertiary: const Color(0xff302500),
      tertiaryContainer: const Color(0xffd5b332),
      onTertiaryContainer: Colors.black,
      error: const Color(0xffffdad6),
      onError: const Color(0xff540003),
      errorContainer: const Color(0xffff5449),
      onErrorContainer: Colors.black,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xffffe5dc),
      outline: const Color(0xfff0cfc4),
      outlineVariant: const Color(0xffcaaea4),
      surfaceBright: const Color(0xff56453e),
      surfaceContainerLowest: const Color(0xff120c0a),
      surfaceContainer: const Color(0xff3a2f29),
      surfaceContainerHigh: const Color(0xff463932),
      surfaceContainerHighest: const Color(0xff52443c),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return darkScheme().copyWith(
      primary: Colors.white,
      surfaceTint: Colors.white,
      onPrimary: Colors.black,
      primaryContainer: const Color(0xffffb4ab),
      onPrimaryContainer: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xffffb77c),
      onSecondaryContainer: Colors.black,
      tertiary: Colors.white,
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xffe7c448),
      onTertiaryContainer: Colors.black,
      error: Colors.white,
      onError: Colors.black,
      errorContainer: const Color(0xffffb4ab),
      onErrorContainer: Colors.black,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white,
      outline: Colors.white,
      outlineVariant: const Color(0xffdec2b7),
      surfaceBright: const Color(0xff604f47),
      surfaceContainerLowest: Colors.black,
      surfaceContainer: const Color(0xff463932),
      surfaceContainerHigh: const Color(0xff52443c),
      surfaceContainerHighest: const Color(0xff5e4e46),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _compactButtonStyle),
    filledButtonTheme: FilledButtonThemeData(style: _compactButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _compactButtonStyle),
    textButtonTheme: TextButtonThemeData(style: _compactButtonStyle),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      indicatorColor: colorScheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: textTheme.labelSmall,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
    ),
  );

  static final ButtonStyle _compactButtonStyle = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(0, 42)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

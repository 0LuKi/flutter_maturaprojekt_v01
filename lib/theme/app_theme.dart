import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {

  static FilledButtonThemeData filledButtonTheme(Color primaryColor, Color onPrimaryColor) =>

    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )
      )
    );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ColorsLight.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ColorsLight.primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF5E9CFA),
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: ColorsLight.surface,
      onSurface: ColorsLight.onSurface,

      // extended Material 3 surfaces
      surfaceContainerHighest: Color(0xFFE6E6E6),
      surfaceContainerHigh: Color.fromARGB(255, 239, 239, 239),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerLow: Color.fromARGB(255, 132, 132, 132),

      // outlines, inverses, etc.
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      inverseSurface: Color(0xFF121212),
      onInverseSurface: Colors.white,
      scrim: Colors.black54,
      shadow: Colors.black26,
      tertiary: Color(0xFF4A7BC7),
      onTertiary: Colors.white,
    ),
    filledButtonTheme: filledButtonTheme(ColorsLight.primary, Colors.white),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ColorsDark.primary,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: ColorsDark.primary,
      onPrimary: ColorsDark.surface,
      secondary: Color(0xFF6CB3F5),
      onSecondary: Colors.black,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      surface: ColorsDark.surface,
      onSurface: ColorsDark.onSurface,

      // extended Material 3 surfaces
      surfaceContainerHighest: Color(0xFF2E2E2E),
      surfaceContainerHigh: Color(0xFF333333),
      surfaceContainer: Color(0xFF2B2B2B),
      surfaceContainerLow: Color(0xFF1E1E1E),

      outline: Color(0xFF5F5F5F),
      outlineVariant: Color(0xFF3A3A3A),
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      scrim: Colors.black87,
      shadow: Colors.black54,
      tertiary: Color(0xFF3E91E0),
      onTertiary: Colors.black,
    ),
  );
}

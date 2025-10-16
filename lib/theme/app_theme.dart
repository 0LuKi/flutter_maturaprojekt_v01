import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ColorsLight.primary,

    colorScheme: ColorScheme.light(
      primary: ColorsLight.primary,
      onPrimary: ColorsLight.surface,
      surface: ColorsLight.surface,
      onSurface: ColorsLight.onSurface,
    )    

  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ColorsLight.primary,

    colorScheme: ColorScheme.dark(
      primary: ColorsDark.primary,
      onPrimary: ColorsDark.surface,
      surface: ColorsDark.surface,
      onSurface: ColorsDark.onSurface,
    )  

  );
}


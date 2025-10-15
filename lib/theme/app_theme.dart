import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    //primaryColor: AppColors.primary,
    //scaffoldBackgroundColor: AppColors.background,

  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    //primaryColor: AppColors.primary,
  );
}


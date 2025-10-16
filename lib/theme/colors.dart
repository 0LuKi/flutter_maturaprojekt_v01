import 'package:flutter/material.dart';

class ColorsLight {
  static const Color surface = Colors.white;
  static const Color onSurface = Colors.black;

  static const Color primary = Color(0xFF326FBB);
  static Color onPrimary(BuildContext context) => Theme.of(context).colorScheme.onPrimary;
  static const Color onPrimaryAccent = Color.fromARGB(255, 239, 239, 239);
  static const Color onPrimaryAccent2 = Color.fromARGB(255, 132, 132, 132);
}

class ColorsDark {
  static const Color surface = Colors.black;
  static const Color onSurface = Colors.white;

  static const Color primary = Color(0xFF64B5F6);
  static Color onPrimary(BuildContext context) => Theme.of(context).colorScheme.onPrimary;
  static const Color onPrimaryAccent = Color.fromARGB(255, 239, 239, 239);
  static const Color onPrimaryAccent2 = Color.fromARGB(255, 132, 132, 132);
}
import 'package:flutter/material.dart';

abstract final class BurnitPalette {
  static const Color primary = Color(0xFF8F9BFF);
  static const Color primarySoft = Color(0xFFB8BFFF);
  static const Color ink = Color(0xFF333333);
  static const Color inkSubtle = Color(0xFF6B7280);
  static const Color surface = Colors.white;

  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF8F9BFF),
      Color(0xFF8492FF),
    ],
  );

  static const Color chipSelectedBg = primary;
  static const Color chipSelectedFg = Colors.white;
  static const Color chipUnselectedBg = Color(0xFFE9ECFF);
  static const Color chipUnselectedFg = primary;

  static const Color outline = primary;
  static const Color outlineSubtle = Color(0x33000000);
}


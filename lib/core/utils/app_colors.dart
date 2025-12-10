import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5A6CF3);
  static const Color primaryDark = Color(0xFF3748C7);

  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF777777);

  static const Color background = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;

  static Gradient get primaryGradient => const LinearGradient(
        colors: [
          Color(0xFF5A6CF3),
          Color(0xFF3C4CE0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

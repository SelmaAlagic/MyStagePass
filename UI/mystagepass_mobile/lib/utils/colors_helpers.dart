import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color background = Color(0xFF0A0E27);
  static const Color cardBackground = Color(0xFF1E2746);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF1E2746)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

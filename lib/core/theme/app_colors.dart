import 'package:flutter/material.dart';

/// Centralized color palette for light and dark themes.
abstract class AppColors {
  static const Color primary = Color(0xFF78856A);
  static const Color primaryLight = Color(0xFFA8B594);
  static const Color primaryDark = Color(0xFF59674D);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF292A25);
  static const Color lightTextSecondary = Color(0xFF77786F);
  static const Color lightBorder = Color(0xFFE9E6DE);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF232420);
  static const Color darkSurface = Color(0xFF302F2A);
  static const Color darkTextPrimary = Color(0xFFF2F0E9);
  static const Color darkTextSecondary = Color(0xFFB7B5AA);
  static const Color darkBorder = Color(0xFF45443D);
}

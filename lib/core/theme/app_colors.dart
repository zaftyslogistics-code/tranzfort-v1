import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Dark Teal - from logo/icon)
  static const Color primary = Color(0xFF008B8B); // Dark Cyan / Teal
  static const Color primaryDark = Color(0xFF006666);
  static const Color primaryLight = Color(0xFF00BFBF);
  static const Color accent = Color(0xFF00CED1); // Lighter teal for highlights

  // Neutral Palette - Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFFE0E0E0);
  
  // Text Colors - Light Theme
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Palette - Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2C2C2C);
  
  // Text Colors - Dark Theme
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Aliases for compatibility
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color danger = error;

  // Overlay Colors
  static Color get lightOverlay => Colors.black.withAlpha((0.4 * 255).round());
  static Color get darkOverlay => Colors.black.withAlpha((0.6 * 255).round());

  // DEPRECATED - Gradients removed in v0.02 flat design
  // Use solid colors instead
  @Deprecated('Use solid primary color instead')
  static const List<Color> primaryGradient = [primary, primary];
  
  // DEPRECATED - Glassmorphism removed in v0.02 flat design
  // Use flat cards with borders instead
  @Deprecated('Use lightSurface with lightBorder instead')
  static const Color glassSurface = lightSurface;
  @Deprecated('Use darkSurface with darkBorder instead')
  static const Color glassBorder = darkBorder;
}

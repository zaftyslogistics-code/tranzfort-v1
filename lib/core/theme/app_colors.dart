import 'package:flutter/material.dart';

class AppColors {
  // Core Brand Colors
  static const Color primary = Color(0xFF00B3B3);
  static const Color primaryVariant = Color(0xFF009999);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF14B8A6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF00D1FF);
  static const Color danger = Color(0xFFE74C3C);

  // Light Theme Colors (aligned with dark UI)
  static const Color lightBackground = Color(0xFF050A1E);
  static const Color lightSurface = Color(0xFF0A0F24);
  static const Color lightOnSurface = Color(0xFFF8F9FB);
  static const Color lightOnBackground = Color(0xFFCBD5E1); // Improved contrast
  static const Color lightBorder = Color(0xFF1E2738);
  static const Color lightDisabled = Color(0xFF64748B); // Better contrast

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF050A1E);
  static const Color darkSurface = Color(0xFF0A0F24);
  static const Color darkSurfaceVariant = Color(0xFF151B2E);
  static const Color darkOnSurface = Color(0xFFF8F9FB);
  static const Color darkOnBackground = Color(0xFF9BA5B8);

  // Neutral Backgrounds
  static const Color mutedBackground = Color(0xFF151B2E);
  static const Color secondaryBackground = Color(0xFF1E2738);

  // Text Colors (WCAG AA compliant - 4.5:1 contrast ratio)
  static const Color textPrimary =
      Color(0xFFFFFFFF); // White on dark backgrounds
  static const Color textSecondary =
      Color(0xFFCCCCCC); // Improved from B0B0B0 for better contrast
  static const Color textTertiary =
      Color(0xFF999999); // Improved from 808080 for better contrast

  // Accent + Focus
  static const Color focusRing = Color(0xFF00B3B3);

  // Semantic Colors for Accessibility
  static const Color errorBackground = Color(0x1AE74C3C);
  static const Color successBackground = Color(0x1A10B981);
  static const Color warningBackground = Color(0x1AF59E0B);
  static const Color infoBackground = Color(0x1A00D1FF);

  // Gradient Colors
  static const List<Color> textGradient = [
    Color(0xFF00D1FF),
    Color(0xFF22D3EE),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF10B981),
  ];
  static const List<Color> primaryGradient = [
    Color(0xFF00D1FF),
    Color(0xFF10B981),
  ];
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFCD34D),
  ];
  static const List<Color> infoGradient = [
    Color(0xFF00D1FF),
    Color(0xFF22D3EE),
  ];
  static const List<Color> dangerGradient = [
    Color(0xFFE74C3C),
    Color(0xFFF87171),
  ];
  static const List<Color> verificationGradient = [
    Color(0xFF22D3EE),
    Color(0xFF10B981),
  ];
  static const List<Color> premiumGradient = [
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
  ];

  // Glassmorphic Surfaces
  static const Color glassSurface = Color(0x1AFFFFFF); // Improved contrast
  static const Color glassSurfaceStrong =
      Color(0x26FFFFFF); // Better visibility
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderStrong = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x66000000);
  static const Color cyanGlow = Color(0x0D00FFFF);
  static const Color cyanGlowStrong = Color(0x1A00FFFF);

  // Overlay Colors
  static Color get lightOverlay => Colors.black.withAlpha((0.4 * 255).round());
  static Color get darkOverlay => Colors.black.withAlpha((0.6 * 255).round());

  // Ad Backgrounds
  static Color get adBackground => Colors.black.withAlpha((0.08 * 255).round());
  static Color get darkAdBackground =>
      Colors.white.withAlpha((0.08 * 255).round());

  // Free Model Colors
  static const Color freeModelGreen = Color(0xFF10B981);
  static const Color freeModelBadge = Color(0xFF059669);
  static const Color truckPrimary = Color(0xFF3B82F6);
  static const Color truckSecondary = Color(0xFF6366F1);
}

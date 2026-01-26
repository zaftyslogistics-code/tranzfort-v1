import 'dart:ui';

// DEPRECATED: Use flat_card.dart instead
// This file is kept for backward compatibility only
// Will be removed in future versions
@Deprecated('Use FlatCard from flat_card.dart instead')
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool showGlow;
  final List<BoxShadow>? boxShadow;
  final bool performanceMode;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.lg),
    this.borderRadius = AppDimensions.radiusLg,
    this.blur = 12,
    this.backgroundColor = AppColors.glassSurface,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 1,
    this.showGlow = false,
    this.boxShadow,
    this.performanceMode = false,
  });

  List<BoxShadow> _buildShadows() {
    if (boxShadow != null) return boxShadow!;
    return [
      const BoxShadow(
        color: AppColors.glassShadow,
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      if (showGlow)
        const BoxShadow(
          color: AppColors.cyanGlowStrong,
          blurRadius: 32,
          spreadRadius: 1,
          offset: Offset(0, 0),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedBackground = (backgroundColor == AppColors.glassSurface)
        ? (isDark ? AppColors.glassSurface : AppColors.lightGlassSurface)
        : backgroundColor;

    final resolvedBorder = (borderColor == AppColors.glassBorder)
        ? (isDark ? AppColors.glassBorder : AppColors.lightGlassBorder)
        : borderColor;

    final shadows = _buildShadows();

    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: resolvedBorder, width: borderWidth),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (performanceMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: container,
      ),
    );
  }
}

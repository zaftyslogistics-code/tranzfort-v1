import 'dart:ui';

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
    final shadows = _buildShadows();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

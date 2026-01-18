import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class CyanGlowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;

  const CyanGlowContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.md),
    this.borderRadius = AppDimensions.radiusLg,
    this.backgroundColor = AppColors.glassSurface,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 1,
    this.glowColor = AppColors.cyanGlowStrong,
    this.blurRadius = 24,
    this.spreadRadius = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}

import 'dart:ui';

// DEPRECATED: Use flat_button.dart instead
// This file is kept for backward compatibility only
// Will be removed in future versions
@Deprecated('Use PrimaryButton, SecondaryButton, or TextButton from flat_button.dart instead')
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

enum GlassmorphicButtonVariant { primary, ghost }

class GlassmorphicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final GlassmorphicButtonVariant variant;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double height;
  final bool showGlow;

  const GlassmorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = GlassmorphicButtonVariant.ghost,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.lg,
      vertical: AppDimensions.sm,
    ),
    this.borderRadius = AppDimensions.radiusMd,
    this.blur = 8,
    this.height = AppDimensions.buttonHeight,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final isPrimary = variant == GlassmorphicButtonVariant.primary;

    final Color backgroundColor = isPrimary
        ? AppColors.primary.withAlpha(((enabled ? 0.9 : 0.4) * 255).round())
        : AppColors.glassSurface
            .withAlpha(((enabled ? 0.6 : 0.3) * 255).round());

    final Color borderColor = isPrimary
        ? AppColors.primaryVariant
            .withAlpha(((enabled ? 0.7 : 0.3) * 255).round())
        : AppColors.glassBorder
            .withAlpha(((enabled ? 1.0 : 0.5) * 255).round());

    final Color textColor = isPrimary
        ? AppColors.darkOnSurface
        : enabled
            ? AppColors.textPrimary
            : AppColors.textTertiary;

    final List<BoxShadow> shadows = [
      BoxShadow(
        color: AppColors.glassShadow,
        blurRadius: enabled ? 18 : 8,
        offset: Offset(0, enabled ? 8 : 4),
      ),
      if (isPrimary && showGlow && enabled)
        BoxShadow(
          color: AppColors.cyanGlowStrong,
          blurRadius: 30,
          spreadRadius: 1,
          offset: Offset(0, 0),
        ),
    ];

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: enabled
                  ? AppColors.primary.withAlpha((0.2 * 255).round())
                  : Colors.transparent,
              highlightColor: enabled
                  ? AppColors.primary.withAlpha((0.1 * 255).round())
                  : Colors.transparent,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: shadows,
                ),
                alignment: Alignment.center,
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

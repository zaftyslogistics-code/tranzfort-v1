import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin-specific button component with consistent styling and variants
class AdminButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AdminButtonVariant variant;
  final AdminButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? child;

  const AdminButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AdminButtonVariant.primary,
    this.size = AdminButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = child ?? _buildButtonContent();

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(buttonChild),
    );
  }

  Widget _buildButton(Widget child) {
    switch (variant) {
      case AdminButtonVariant.primary:
        return _buildPrimaryButton(child);
      case AdminButtonVariant.secondary:
        return _buildSecondaryButton(child);
      case AdminButtonVariant.outline:
        return _buildOutlineButton(child);
      case AdminButtonVariant.ghost:
        return _buildGhostButton(child);
      case AdminButtonVariant.danger:
        return _buildDangerButton(child);
      case AdminButtonVariant.success:
        return _buildSuccessButton(child);
    }
  }

  Widget _buildPrimaryButton(Widget child) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevation2,
        shadowColor: AppColors.cyanGlowStrong,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildSecondaryButton(Widget child) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildOutlineButton(Widget child) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildGhostButton(Widget child) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildDangerButton(Widget child) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevation1,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildSuccessButton(Widget child) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevation1,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        minimumSize: _getMinimumSize(),
      ),
      child: child,
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AdminButtonVariant.ghost
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppDimensions.sm),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AdminButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        );
      case AdminButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.sm,
        );
      case AdminButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.xl,
          vertical: AppDimensions.md,
        );
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case AdminButtonSize.small:
        return const Size(0, 32);
      case AdminButtonSize.medium:
        return const Size(0, 44);
      case AdminButtonSize.large:
        return const Size(0, 52);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AdminButtonSize.small:
        return 12;
      case AdminButtonSize.medium:
        return 14;
      case AdminButtonSize.large:
        return 16;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case AdminButtonSize.small:
        return 16;
      case AdminButtonSize.medium:
        return 18;
      case AdminButtonSize.large:
        return 20;
    }
  }
}

enum AdminButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
}

enum AdminButtonSize {
  small,
  medium,
  large,
}

/// Admin button group for consistent button layouts
class AdminButtonGroup extends StatelessWidget {
  final List<AdminButton> buttons;
  final AdminButtonGroupDirection direction;
  final double spacing;

  const AdminButtonGroup({
    super.key,
    required this.buttons,
    this.direction = AdminButtonGroupDirection.horizontal,
    this.spacing = AppDimensions.md,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == AdminButtonGroupDirection.horizontal) {
      return Row(
        children: buttons
            .map((button) => Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: button,
                ))
            .toList(),
      );
    } else {
      return Column(
        children: buttons
            .map((button) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: button,
                ))
            .toList(),
      );
    }
  }
}

enum AdminButtonGroupDirection {
  horizontal,
  vertical,
}

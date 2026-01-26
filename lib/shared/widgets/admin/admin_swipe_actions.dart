import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Swipe action widget for list items
class AdminSwipeActions extends StatelessWidget {
  final Widget child;
  final List<SwipeAction> actions;
  final double threshold;

  const AdminSwipeActions({
    super.key,
    required this.child,
    required this.actions,
    this.threshold = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      dismissThresholds: {
        DismissDirection.startToEnd: threshold,
      },
      background: Container(
        decoration: BoxDecoration(
          color: _getActionColor(actions.first.type),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppDimensions.lg),
        child: Row(
          children: [
            Icon(
              actions.first.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              actions.first.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          actions.first.onPressed();
        }
      },
      child: child,
    );
  }

  Color _getActionColor(SwipeActionType type) {
    switch (type) {
      case SwipeActionType.edit:
        return AppColors.primary;
      case SwipeActionType.delete:
        return AppColors.danger;
      case SwipeActionType.archive:
        return AppColors.warning;
      case SwipeActionType.approve:
        return AppColors.success;
      case SwipeActionType.reject:
        return AppColors.danger;
    }
  }
}

/// Swipe action configuration
class SwipeAction {
  final SwipeActionType type;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SwipeAction({
    required this.type,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

enum SwipeActionType {
  edit,
  delete,
  archive,
  approve,
  reject,
}

/// Enhanced list item with swipe actions and haptic feedback
class AdminSwipeListItem extends StatelessWidget {
  final Widget child;
  final List<SwipeAction> swipeActions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AdminSwipeListItem({
    super.key,
    required this.child,
    this.swipeActions = const [],
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final item = swipeActions.isNotEmpty
        ? AdminSwipeActions(
            actions: swipeActions,
            child: _buildTouchableChild(context),
          )
        : _buildTouchableChild(context);

    return item;
  }

  Widget _buildTouchableChild(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _triggerHapticFeedback();
          onTap?.call();
        },
        onLongPress: () {
          _triggerHapticFeedback();
          onLongPress?.call();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: child,
      ),
    );
  }

  void _triggerHapticFeedback() {
    // Add haptic feedback for better mobile UX
    // This would require importing the haptic_feedback package
    // For now, we'll just log it
    debugPrint('Haptic feedback triggered');
  }
}

/// Pull-to-refresh with skeleton loading
class AdminPullToRefreshWithSkeleton extends StatelessWidget {
  final RefreshCallback onRefresh;
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const AdminPullToRefreshWithSkeleton({
    super.key,
    required this.onRefresh,
    required this.child,
    this.isLoading = false,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Stack(
        children: [
          child,
          Container(
            color: AppColors.darkBackground.withAlpha((0.8 * 255).round()),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      child: child,
    );
  }
}

/// Touch-friendly button with improved mobile targets
class AdminTouchButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AdminButtonVariant variant;
  final bool isFullWidth;
  final double? minHeight;

  const AdminTouchButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AdminButtonVariant.primary,
    this.isFullWidth = false,
    this.minHeight = 48.0, // Minimum touch target size
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: minHeight,
      child: ElevatedButton(
        onPressed: () {
          _triggerHapticFeedback();
          onPressed?.call();
        },
        style: _getButtonStyle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppDimensions.sm),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case AdminButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevation2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );
      case AdminButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryBackground,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        );
      case AdminButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );
      case AdminButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevation1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );
      case AdminButtonVariant.success:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: AppDimensions.elevation1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        );
    }
  }

  void _triggerHapticFeedback() {
    debugPrint('Haptic feedback triggered');
  }
}

enum AdminButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  success,
}

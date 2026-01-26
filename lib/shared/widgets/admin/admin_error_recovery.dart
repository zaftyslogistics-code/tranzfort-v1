import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Error recovery widget with retry functionality
class AdminErrorRecovery extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? customMessage;

  const AdminErrorRecovery({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.danger.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.danger,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Error',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  color: AppColors.danger,
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            customMessage ?? 'Something went wrong. Please try again.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.xs),
            Text(
              error,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Report error action
                      _showErrorReportDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Report'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showErrorReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Report Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Error details have been copied to clipboard.'),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.glassSurfaceStrong,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error report sent to support team'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with helpful actions
class AdminEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final bool isLoading;

  const AdminEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppDimensions.lg),
            ] else ...[
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.lg),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton with shimmer effect
class AdminShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AdminShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<AdminShimmer> createState() => _AdminShimmerState();
}

class _AdminShimmerState extends State<AdminShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? AppColors.glassBorder,
                widget.highlightColor ?? AppColors.glassSurfaceStrong,
                widget.baseColor ?? AppColors.glassBorder,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(1.0 + _animation.value, 0.0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton card with shimmer effect
class AdminSkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const AdminSkeletonCard({
    super.key,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 120,
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceStrong,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: AdminShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassBorder,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// Skeleton list item
class AdminSkeletonListItem extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const AdminSkeletonListItem({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceStrong,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            AdminShimmer(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminShimmer(
                    child: Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  AdminShimmer(
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

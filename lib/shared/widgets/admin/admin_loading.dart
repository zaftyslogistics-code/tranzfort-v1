import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin-specific loading components with skeleton loaders
class AdminLoading extends StatelessWidget {
  final AdminLoadingType type;
  final String? message;
  final double? height;
  final double? width;

  const AdminLoading({
    super.key,
    this.type = AdminLoadingType.spinner,
    this.message,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AdminLoadingType.spinner:
        return _buildSpinner();
      case AdminLoadingType.skeletonCard:
        return _buildSkeletonCard();
      case AdminLoadingType.skeletonList:
        return _buildSkeletonList();
      case AdminLoadingType.skeletonTable:
        return _buildSkeletonTable();
      case AdminLoadingType.skeletonChart:
        return _buildSkeletonChart();
      case AdminLoadingType.fullscreen:
        return _buildFullscreen();
    }
  }

  Widget _buildSpinner() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.md),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: height ?? 120,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceStrong,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonLine(width: 120, height: 16),
            const SizedBox(height: AppDimensions.sm),
            _buildSkeletonLine(height: 12),
            const SizedBox(height: AppDimensions.xs),
            _buildSkeletonLine(width: 200, height: 12),
            const Spacer(),
            _buildSkeletonLine(width: 80, height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.glassSurfaceStrong,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                children: [
                  _buildSkeletonCircle(size: 40),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonLine(width: 120, height: 14),
                        const SizedBox(height: AppDimensions.xs),
                        _buildSkeletonLine(width: double.infinity, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonTable() {
    return Column(
      children: [
        // Header
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.glassSurfaceStrong,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  child: _buildSkeletonLine(height: 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        // Rows
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.xs),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassSurfaceStrong,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      child: _buildSkeletonLine(height: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonChart() {
    return Container(
      height: height ?? 200,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceStrong,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonLine(width: 100, height: 14),
            const SizedBox(height: AppDimensions.md),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: 20 + (index * 15) % 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreen() {
    return Container(
      color: AppColors.darkBackground.withAlpha((0.8 * 255).round()),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(height: AppDimensions.lg),
                Text(
                  message!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLine({double? width, double height = 12}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSkeletonCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.glassBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

enum AdminLoadingType {
  spinner,
  skeletonCard,
  skeletonList,
  skeletonTable,
  skeletonChart,
  fullscreen,
}

/// Loading overlay for any widget
class AdminLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final AdminLoadingType loadingType;

  const AdminLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.loadingType = AdminLoadingType.fullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          Container(
            color: AppColors.darkBackground.withAlpha((0.8 * 255).round()),
            child: AdminLoading(
              type: loadingType,
              message: message,
            ),
          ),
        ],
      ],
    );
  }
}

/// Pull-to-refresh loading indicator
class AdminPullToRefresh extends StatelessWidget {
  final RefreshCallback onRefresh;
  final Widget child;
  final String? refreshMessage;

  const AdminPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshMessage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.darkSurface,
      child: child,
    );
  }
}

/// Empty state widget with loading skeleton
class AdminEmptyStateWithSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget? child;
  final String? emptyMessage;
  final String? loadingMessage;
  final Widget? action;

  const AdminEmptyStateWithSkeleton({
    super.key,
    required this.isLoading,
    this.child,
    this.emptyMessage,
    this.loadingMessage,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AdminLoading(
        type: AdminLoadingType.skeletonList,
        message: loadingMessage,
      );
    }

    return child ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                emptyMessage ?? 'No data available',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppDimensions.lg),
                action!,
              ],
            ],
          ),
        );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showAd;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.showAd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xl),
              decoration: BoxDecoration(
                color: AppColors.glassSurfaceStrong,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.xl,
                    vertical: AppDimensions.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

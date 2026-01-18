import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';

class IntentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  const IntentCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.glassBorder;
    final iconGradient = isSelected
        ? AppColors.primaryGradient
        : [
            AppColors.glassSurfaceStrong,
            AppColors.glassSurface,
          ];

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        blur: isSelected ? 16 : 12,
        showGlow: isSelected,
        borderRadius: AppDimensions.radiusLg,
        padding: const EdgeInsets.all(AppDimensions.lg),
        borderColor: borderColor,
        backgroundColor: isSelected
            ? AppColors.glassSurfaceStrong
            : AppColors.glassSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: iconGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                icon,
                size: 44,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

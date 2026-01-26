/// TruckTypeChip Widget
/// 
/// A visual chip for selecting truck categories.
/// Shows category icon, name, and ton range.

import 'package:flutter/material.dart';

import '../../core/constants/truck_categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class TruckTypeChip extends StatelessWidget {
  final TruckCategoryData category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showTonRange;
  final bool compact;

  const TruckTypeChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showTonRange = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppDimensions.paddingSmall : AppDimensions.paddingMedium,
          vertical: compact ? AppDimensions.paddingXSmall : AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.icon,
                  style: TextStyle(
                    fontSize: compact ? 16 : 20,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ],
            ),
            if (showTonRange && !compact) ...[
              const SizedBox(height: 2),
              Text(
                category.tonRangeDisplay,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.8)
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "More" chip to show additional categories
class TruckTypeMoreChip extends StatelessWidget {
  final int additionalCount;
  final bool hasSelections;
  final VoidCallback? onTap;

  const TruckTypeMoreChip({
    super.key,
    required this.additionalCount,
    this.hasSelections = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: hasSelections
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: hasSelections
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.3),
            width: hasSelections ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'More',
              style: TextStyle(
                color: hasSelections
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: hasSelections
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            if (hasSelections) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$additionalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

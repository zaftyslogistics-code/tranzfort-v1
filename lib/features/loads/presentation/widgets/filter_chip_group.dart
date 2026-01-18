import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.xs,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.primary.withAlpha((0.2 * 255).round()),
          backgroundColor: AppColors.glassSurface,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
          ),
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        );
      }).toList(),
    );
  }
}

/// TruckTypeChipBar Widget
/// 
/// Horizontal scrollable bar of truck category chips.
/// First 4 categories always visible, "More" chip for additional categories.

import 'package:flutter/material.dart';

import '../../core/constants/truck_categories.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/truck_type.dart';
import 'truck_type_chip.dart';
import 'truck_type_sheet.dart';

class TruckTypeChipBar extends StatelessWidget {
  final TruckTypeSelection selection;
  final ValueChanged<TruckTypeSelection> onSelectionChanged;
  final bool multiSelect;
  final EdgeInsets padding;

  const TruckTypeChipBar({
    super.key,
    required this.selection,
    required this.onSelectionChanged,
    this.multiSelect = true,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
  });

  @override
  Widget build(BuildContext context) {
    // Count selections in secondary categories
    final secondarySelectionCount = kSecondaryTruckCategories
        .where((id) => selection.hasCategory(id))
        .length;

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          // Primary categories (always visible)
          ...kPrimaryTruckCategories.map((categoryId) {
            final category = getTruckCategoryById(categoryId)!;
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
              child: TruckTypeChip(
                category: category,
                isSelected: selection.hasCategory(categoryId),
                onTap: () => _onCategoryTap(context, categoryId),
              ),
            );
          }),

          // "More" chip for secondary categories
          TruckTypeMoreChip(
            additionalCount: secondarySelectionCount,
            hasSelections: secondarySelectionCount > 0,
            onTap: () => _showMoreCategories(context),
          ),
        ],
      ),
    );
  }

  void _onCategoryTap(BuildContext context, TruckCategoryId categoryId) {
    if (multiSelect) {
      // Toggle category selection
      final newSelection = selection.toggleCategory(categoryId);
      onSelectionChanged(newSelection);

      // If selected and category has sub-options, show bottom sheet
      if (newSelection.hasCategory(categoryId)) {
        final category = getTruckCategoryById(categoryId);
        if (category != null && category.availableSubOptions.length > 1) {
          _showSubOptionsSheet(context, categoryId);
        }
      }
    } else {
      // Single select mode - replace selection
      if (selection.hasCategory(categoryId)) {
        onSelectionChanged(const TruckTypeSelection());
      } else {
        onSelectionChanged(TruckTypeSelection(
          selectedCategories: {categoryId},
        ));

        // Show sub-options if available
        final category = getTruckCategoryById(categoryId);
        if (category != null && category.availableSubOptions.length > 1) {
          _showSubOptionsSheet(context, categoryId);
        }
      }
    }
  }

  void _showSubOptionsSheet(BuildContext context, TruckCategoryId categoryId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TruckTypeSheet(
        categoryId: categoryId,
        currentSelection: selection.getSpecsForCategory(categoryId),
        onApply: (truckType) {
          final newSelection = selection.updateSpecs(categoryId, truckType);
          onSelectionChanged(newSelection);
          Navigator.pop(context);
        },
        onClear: () {
          // Keep category selected but clear specs
          final newSelection = selection.updateSpecs(
            categoryId,
            TruckType.fromCategory(categoryId),
          );
          onSelectionChanged(newSelection);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMoreCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoreCategoriesSheet(
        selection: selection,
        onSelectionChanged: (newSelection) {
          onSelectionChanged(newSelection);
        },
        onCategoryTapForSpecs: (categoryId) {
          Navigator.pop(context);
          _showSubOptionsSheet(context, categoryId);
        },
      ),
    );
  }
}

/// Bottom sheet showing additional truck categories
class _MoreCategoriesSheet extends StatefulWidget {
  final TruckTypeSelection selection;
  final ValueChanged<TruckTypeSelection> onSelectionChanged;
  final ValueChanged<TruckCategoryId> onCategoryTapForSpecs;

  const _MoreCategoriesSheet({
    required this.selection,
    required this.onSelectionChanged,
    required this.onCategoryTapForSpecs,
  });

  @override
  State<_MoreCategoriesSheet> createState() => _MoreCategoriesSheetState();
}

class _MoreCategoriesSheetState extends State<_MoreCategoriesSheet> {
  late TruckTypeSelection _localSelection;

  @override
  void initState() {
    super.initState();
    _localSelection = widget.selection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'More Truck Types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Categories grid
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: kSecondaryTruckCategories.map((categoryId) {
                final category = getTruckCategoryById(categoryId)!;
                return TruckTypeChip(
                  category: category,
                  isSelected: _localSelection.hasCategory(categoryId),
                  onTap: () {
                    setState(() {
                      _localSelection = _localSelection.toggleCategory(categoryId);
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Footer buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Clear only secondary categories
                      var newSelection = _localSelection;
                      for (final id in kSecondaryTruckCategories) {
                        if (newSelection.hasCategory(id)) {
                          newSelection = newSelection.toggleCategory(id);
                        }
                      }
                      widget.onSelectionChanged(newSelection);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelectionChanged(_localSelection);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

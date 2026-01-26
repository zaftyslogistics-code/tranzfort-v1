/// TruckTypeSheet Widget
/// 
/// Bottom sheet for selecting truck sub-options (length, wheeler, axle, ton range).
/// Shows options specific to the selected category.

import 'package:flutter/material.dart';

import '../../core/constants/truck_categories.dart';
import '../../core/constants/truck_sub_options.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/truck_type.dart';

class TruckTypeSheet extends StatefulWidget {
  final TruckCategoryId categoryId;
  final TruckType? currentSelection;
  final ValueChanged<TruckType> onApply;
  final VoidCallback onClear;

  const TruckTypeSheet({
    super.key,
    required this.categoryId,
    this.currentSelection,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<TruckTypeSheet> createState() => _TruckTypeSheetState();
}

class _TruckTypeSheetState extends State<TruckTypeSheet> {
  late TruckType _selection;
  late TruckSubOptions _subOptions;
  late TruckCategoryData _category;

  @override
  void initState() {
    super.initState();
    _category = getTruckCategoryById(widget.categoryId)!;
    _subOptions = getSubOptionsForCategory(widget.categoryId);
    _selection = widget.currentSelection ?? TruckType.fromCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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

          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Length options
                  if (_subOptions.lengths != null && _subOptions.lengths!.isNotEmpty)
                    _buildLengthSection(),

                  // Wheeler options
                  if (_subOptions.wheelers != null && _subOptions.wheelers!.isNotEmpty)
                    _buildWheelerSection(),

                  // Axle options
                  if (_subOptions.axles != null && _subOptions.axles!.isNotEmpty)
                    _buildAxleSection(),

                  // Body type options
                  if (_subOptions.bodyTypes != null && _subOptions.bodyTypes!.isNotEmpty)
                    _buildBodyTypeSection(),

                  // Model options
                  if (_subOptions.models != null && _subOptions.models!.isNotEmpty)
                    _buildModelSection(),

                  // Ton range options (always shown)
                  if (_subOptions.tonRanges.isNotEmpty)
                    _buildTonRangeSection(),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Footer buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_selection),
                    child: const Text('Show Loads'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLengthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Length'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.lengths!.map((length) {
            final isSelected = _selection.lengthFt == length.feet;
            return _OptionChip(
              label: length.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selection = _selection.copyWith(
                    lengthFt: isSelected ? null : length.feet,
                    clearLength: isSelected,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildWheelerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Wheeler'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.wheelers!.map((wheeler) {
            final isSelected = _selection.wheelerCount == wheeler.count;
            return _OptionChip(
              label: wheeler.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selection = _selection.copyWith(
                    wheelerCount: isSelected ? null : wheeler.count,
                    clearWheeler: isSelected,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildAxleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Axle Type'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.axles!.map((axle) {
            final isSelected = _selection.axleType == axle;
            return _OptionChip(
              label: axle.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selection = _selection.copyWith(
                    axleType: isSelected ? null : axle,
                    clearAxle: isSelected,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildBodyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Body Type'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.bodyTypes!.map((bodyType) {
            final isSelected = _selection.bodyType == bodyType;
            return _OptionChip(
              label: bodyType.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selection = _selection.copyWith(
                    bodyType: isSelected ? null : bodyType,
                    clearBody: isSelected,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Model'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.models!.map((model) {
            final isSelected = _selection.model == model;
            return _OptionChip(
              label: model.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selection = _selection.copyWith(
                    model: isSelected ? null : model,
                    clearModel: isSelected,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildTonRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Passing Ton'),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: _subOptions.tonRanges.map((range) {
            final isSelected = _selection.passingTonMin == range.minTon &&
                _selection.passingTonMax == range.maxTon;
            return _OptionChip(
              label: range.display,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    // Reset to category defaults
                    _selection = _selection.copyWith(
                      passingTonMin: _category.minTon,
                      passingTonMax: _category.maxTon,
                    );
                  } else {
                    _selection = _selection.copyWith(
                      passingTonMin: range.minTon,
                      passingTonMax: range.maxTon,
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual option chip within the sheet
class _OptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

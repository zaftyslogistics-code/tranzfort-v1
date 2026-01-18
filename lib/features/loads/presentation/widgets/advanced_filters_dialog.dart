import 'package:flutter/material.dart';
import 'package:transfort_app/core/theme/app_colors.dart';
import 'package:transfort_app/core/theme/app_dimensions.dart';
import 'package:transfort_app/shared/widgets/glassmorphic_card.dart';

class AdvancedFiltersDialog extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final double? minWeight;
  final double? maxWeight;
  final DateTimeRange? dateRange;
  final Function(double?, double?, double?, double?, DateTimeRange?) onApply;

  const AdvancedFiltersDialog({
    super.key,
    this.minPrice,
    this.maxPrice,
    this.minWeight,
    this.maxWeight,
    this.dateRange,
    required this.onApply,
  });

  @override
  State<AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<AdvancedFiltersDialog> {
  late RangeValues _priceRange;
  late RangeValues _weightRange;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.minPrice ?? 0,
      widget.maxPrice ?? 100000,
    );
    _weightRange = RangeValues(
      widget.minWeight ?? 0,
      widget.maxWeight ?? 50,
    );
    _selectedDateRange = widget.dateRange;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.darkSurface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100000);
      _weightRange = const RangeValues(0, 50);
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicCard(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              
              // Price Range
              Text(
                'Price Range',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppDimensions.sm),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100000,
                divisions: 100,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.textSecondary.withValues(alpha: 0.3),
                labels: RangeLabels(
                  '₹${_priceRange.start.toInt()}',
                  '₹${_priceRange.end.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${_priceRange.start.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    '₹${_priceRange.end.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              // Weight Range
              Text(
                'Weight Range (tons)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppDimensions.sm),
              RangeSlider(
                values: _weightRange,
                min: 0,
                max: 50,
                divisions: 50,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.textSecondary.withValues(alpha: 0.3),
                labels: RangeLabels(
                  '${_weightRange.start.toInt()}t',
                  '${_weightRange.end.toInt()}t',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _weightRange = values;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_weightRange.start.toInt()} tons',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    '${_weightRange.end.toInt()} tons',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              // Date Range
              Text(
                'Loading Date Range',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppDimensions.sm),
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _selectedDateRange == null
                      ? 'Select Date Range'
                      : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.lightBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.lightBorder),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _priceRange.start == 0 ? null : _priceRange.start,
                          _priceRange.end == 100000 ? null : _priceRange.end,
                          _weightRange.start == 0 ? null : _weightRange.start,
                          _weightRange.end == 50 ? null : _weightRange.end,
                          _selectedDateRange,
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

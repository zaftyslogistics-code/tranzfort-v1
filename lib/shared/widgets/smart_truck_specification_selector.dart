import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../features/fleet/domain/entities/truck_specification.dart';

class SmartTruckSpecificationSelector extends StatefulWidget {
  final TruckSpecification? initialSpec;
  final Function(TruckSpecification) onSpecificationSelected;

  const SmartTruckSpecificationSelector({
    super.key,
    this.initialSpec,
    required this.onSpecificationSelected,
  });

  @override
  State<SmartTruckSpecificationSelector> createState() =>
      _SmartTruckSpecificationSelectorState();
}

class _SmartTruckSpecificationSelectorState
    extends State<SmartTruckSpecificationSelector> {
  int _selectedCategory = 0; // 0: Small, 1: Medium, 2: Heavy, 3: Super Heavy
  TruckSpecification? _selectedSpec;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Small Trucks',
      'icon': Icons.local_shipping_outlined,
      'color': AppColors.success,
      'description': '0-5 tons • City transport',
      'specs': TruckSpecification.getSmartIndianTruckSpecifications()
          .where((spec) => spec.maxCapacity <= 5)
          .toList(),
    },
    {
      'name': 'Medium Trucks',
      'icon': Icons.local_shipping,
      'color': AppColors.truckPrimary,
      'description': '5-15 tons • Regional transport',
      'specs': TruckSpecification.getSmartIndianTruckSpecifications()
          .where((spec) => spec.maxCapacity > 5 && spec.maxCapacity <= 15)
          .toList(),
    },
    {
      'name': 'Heavy Trucks',
      'icon': Icons.local_shipping,
      'color': AppColors.warning,
      'description': '15-25 tons • Long haul',
      'specs': TruckSpecification.getSmartIndianTruckSpecifications()
          .where((spec) => spec.maxCapacity > 15 && spec.maxCapacity <= 25)
          .toList(),
    },
    {
      'name': 'Super Heavy',
      'icon': Icons.local_shipping,
      'color': AppColors.danger,
      'description': '25+ tons • Bulk transport',
      'specs': TruckSpecification.getSmartIndianTruckSpecifications()
          .where((spec) => spec.maxCapacity > 25)
          .toList(),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSpec != null) {
      _selectedSpec = widget.initialSpec;
      _selectedCategory = _findCategoryForSpec(widget.initialSpec!);
    }
  }

  int _findCategoryForSpec(TruckSpecification spec) {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i]['specs'].contains(spec)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      backgroundColor: AppColors.glassSurfaceStrong,
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            'Select Truck Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Choose the category that best fits your truck',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Category Selection
          _buildCategorySelector(),
          const SizedBox(height: AppDimensions.lg),

          // Specification Details
          _buildSpecificationDetails(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
                _selectedSpec = null; // Reset spec when category changes
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: AppDimensions.sm),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          category['color'],
                          category['color'].withAlpha((0.8 * 255).round())
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.glassSurface,
                          AppColors.glassSurface
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: isSelected ? category['color'] : AppColors.glassBorder,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : category['color'],
                    size: 32,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    category['name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : category['color'],
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withAlpha((0.9 * 255).round())
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecificationDetails() {
    final specs =
        _categories[_selectedCategory]['specs'] as List<TruckSpecification>;

    if (specs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Center(
          child: Text(
            'No specifications available for this category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Options',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.sm),
        ...specs.map((spec) => _buildSpecificationCard(spec)),
      ],
    );
  }

  Widget _buildSpecificationCard(TruckSpecification spec) {
    final isSelected = _selectedSpec?.id == spec.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpec = spec;
          widget.onSpecificationSelected(spec);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.truckPrimary, AppColors.truckSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [AppColors.glassSurface, AppColors.glassSurface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.truckPrimary : AppColors.glassBorder,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${spec.tyreCount} Tyres • ${spec.bodyType}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isSelected ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.capacityRange,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white.withAlpha((0.9 * 255).round())
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      'SELECTED',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                    ),
                  ),
              ],
            ),
            if (spec.length != null &&
                spec.width != null &&
                spec.height != null)
              const SizedBox(height: AppDimensions.sm),
            if (spec.length != null &&
                spec.width != null &&
                spec.height != null)
              Text(
                'Dimensions: ${spec.dimensions}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Colors.white.withAlpha((0.9 * 255).round())
                          : AppColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for quick truck type selection
class QuickTruckTypeSelector extends StatelessWidget {
  final Function(TruckSpecification) onSelected;
  final TruckSpecification? selectedSpec;

  const QuickTruckTypeSelector({
    super.key,
    required this.onSelected,
    this.selectedSpec,
  });

  @override
  Widget build(BuildContext context) {
    final specs = TruckSpecification.getSmartIndianTruckSpecifications();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specs.length,
        itemBuilder: (context, index) {
          final spec = specs[index];
          final isSelected = selectedSpec?.id == spec.id;

          return GestureDetector(
            onTap: () => onSelected(spec),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: AppDimensions.sm),
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.truckPrimary,
                          AppColors.truckSecondary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.glassSurface,
                          AppColors.glassSurface
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(
                  color: isSelected
                      ? AppColors.truckPrimary
                      : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${spec.tyreCount}T',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.truckPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.bodyType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withAlpha((0.9 * 255).round())
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.capacityRange,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withAlpha((0.9 * 255).round())
                              : AppColors.textSecondary,
                          fontSize: 9,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

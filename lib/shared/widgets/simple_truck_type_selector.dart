import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';

class SimpleTruckTypeSelector extends StatefulWidget {
  final String? initialType;
  final Function(String) onTruckTypeSelected;

  const SimpleTruckTypeSelector({
    super.key,
    this.initialType,
    required this.onTruckTypeSelected,
  });

  @override
  State<SimpleTruckTypeSelector> createState() =>
      _SimpleTruckTypeSelectorState();
}

class _SimpleTruckTypeSelectorState extends State<SimpleTruckTypeSelector> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    if (_selectedType != null &&
        _truckTypes.every((t) => t['name'] != _selectedType)) {
      _truckTypes.insert(
        0,
        {
          'name': _selectedType,
          'category': 'Legacy',
          'capacity': null,
          'icon': Icons.local_shipping,
        },
      );
    }
  }

  final List<Map<String, dynamic>> _truckTypes = [
    {
      'name': 'Open Body',
      'category': 'Body Type',
      'capacity': null,
      'icon': Icons.local_shipping,
    },
    {
      'name': 'Flat Body',
      'category': 'Body Type',
      'capacity': null,
      'icon': Icons.local_shipping,
    },
    {
      'name': 'Bulker',
      'category': 'Body Type',
      'capacity': null,
      'icon': Icons.local_shipping,
    },
    {
      'name': 'Container',
      'category': 'Body Type',
      'capacity': null,
      'icon': Icons.local_shipping,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          'Select Truck Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.md),
        ..._truckTypes.map((truck) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassmorphicCard(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = truck['name'] as String;
                      });
                      widget.onTruckTypeSelected(truck['name'] as String);
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Row(
                      children: [
                        Icon(
                          truck['icon'] as IconData,
                          color: _selectedType == truck['name']
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 32,
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                truck['name'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: _selectedType == truck['name']
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                '${truck['category']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedType == truck['name'])
                          const Icon(Icons.check_circle,
                              color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

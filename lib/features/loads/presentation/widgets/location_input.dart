import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import 'load_form_field.dart';

class LocationInput extends StatelessWidget {
  final String label;
  final TextEditingController locationController;
  final TextEditingController cityController;
  final TextEditingController stateController;

  const LocationInput({
    super.key,
    required this.label,
    required this.locationController,
    required this.cityController,
    required this.stateController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.sm),
        LoadFormField(
          label: 'Full Address',
          controller: locationController,
          hint: 'Enter full address or landmark',
          validator: (value) => Validators.validateRequired(value, 'address'),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: LoadFormField(
                label: 'City',
                controller: cityController,
                hint: 'City name',
                validator: (value) => Validators.validateRequired(value, 'city'),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: LoadFormField(
                label: 'State',
                controller: stateController,
                hint: 'Optional',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

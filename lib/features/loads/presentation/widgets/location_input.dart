import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import 'load_form_field.dart';
import 'address_autocomplete_field.dart';

class LocationInput extends StatelessWidget {
  final String label;
  final TextEditingController locationController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final void Function(double? lat, double? lng)? onCoordinates;

  const LocationInput({
    super.key,
    required this.label,
    required this.locationController,
    required this.cityController,
    required this.stateController,
    this.onCoordinates,
  });

  Future<void> _useCurrentLocation(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final places = NominatimPlacesService();
    final suggestion = await places.reverse(lat: pos.latitude, lng: pos.longitude);

    if (suggestion == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to resolve current address')),
        );
      }
      return;
    }

    locationController.text = suggestion.displayName;
    if (suggestion.city != null && suggestion.city!.trim().isNotEmpty) {
      cityController.text = suggestion.city!.trim();
    }
    if (suggestion.state != null && suggestion.state!.trim().isNotEmpty) {
      stateController.text = suggestion.state!.trim();
    }

    onCoordinates?.call(suggestion.lat, suggestion.lng);
  }

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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _useCurrentLocation(context),
            icon: const Icon(Icons.my_location, size: 16),
            label: const Text('Use my current location'),
          ),
        ),
        AddressAutocompleteField(
          label: 'Full Address',
          addressController: locationController,
          cityController: cityController,
          stateController: stateController,
          hint: 'Enter full address or landmark',
          validator: (value) => Validators.validateRequired(value, 'address'),
          onSelected: (s) => onCoordinates?.call(s.lat, s.lng),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: LoadFormField(
                label: 'City',
                controller: cityController,
                hint: 'City name',
                validator: (value) =>
                    Validators.validateRequired(value, 'city'),
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

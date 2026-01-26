import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_input.dart';

/// Trucker Find Loads Screen v0.02
/// Entry screen for truckers to search loads
/// - From location picker
/// - To location picker
/// - "Use current location" button
/// - "Find Loads" CTA (bottom, thumb-friendly)
class TruckerFindScreen extends ConsumerStatefulWidget {
  const TruckerFindScreen({super.key});

  @override
  ConsumerState<TruckerFindScreen> createState() => _TruckerFindScreenState();
}

class _TruckerFindScreenState extends ConsumerState<TruckerFindScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    // TODO: Implement geolocation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting your location...')),
    );
  }

  void _findLoads() {
    if (!_formKey.currentState!.validate()) return;

    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    // Navigate to results screen
    context.push('/trucker/results?from=$from&to=$to');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Find Loads'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Where are you going?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find loads along your route',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // From Location
                      FlatInput(
                        label: 'From',
                        hint: 'Pickup location',
                        controller: _fromController,
                        prefixIcon: const Icon(Icons.location_on, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup location';
                          }
                          return null;
                        },
                        onTap: () {
                          // TODO: Open location picker
                        },
                      ),
                      const SizedBox(height: 16),

                      // Swap button
                      Center(
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.swap_vert,
                              color: AppColors.primary,
                            ),
                          ),
                          onPressed: () {
                            final temp = _fromController.text;
                            _fromController.text = _toController.text;
                            _toController.text = temp;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // To Location
                      FlatInput(
                        label: 'To',
                        hint: 'Delivery location',
                        controller: _toController,
                        prefixIcon: const Icon(Icons.location_on, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery location';
                          }
                          return null;
                        },
                        onTap: () {
                          // TODO: Open location picker
                        },
                      ),
                      const SizedBox(height: 24),

                      // Use Current Location Button
                      SecondaryButton(
                        text: 'Use Current Location',
                        icon: Icons.my_location,
                        onPressed: _useCurrentLocation,
                      ),
                      const SizedBox(height: 16),

                      // Recent Searches (Optional)
                      if (false) ...[
                        Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // TODO: Add recent searches list
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom CTA (Thumb-friendly zone)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: PrimaryButton(
                text: 'Find Loads',
                icon: Icons.search,
                onPressed: _findLoads,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

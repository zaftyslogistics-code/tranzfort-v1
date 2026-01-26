import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_input.dart';
import '../../../../shared/widgets/flat_dropdown.dart';

/// Post Load Screen v0.02
/// Simplified single-page form with max 5 fields
/// Flat design
class PostLoadScreenV2 extends ConsumerStatefulWidget {
  const PostLoadScreenV2({super.key});

  @override
  ConsumerState<PostLoadScreenV2> createState() => _PostLoadScreenV2State();
}

class _PostLoadScreenV2State extends ConsumerState<PostLoadScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? _selectedMaterial;
  String? _selectedTruckType;
  bool _isLoading = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitLoad() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Submit to backend
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Show success and navigate
    context.go('/my-loads');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Load posted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Post Load'),
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
                        'Post a New Load',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details below',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Field 1: From Location
                      FlatInput(
                        label: 'From Location',
                        hint: 'Pickup city',
                        controller: _fromController,
                        prefixIcon: const Icon(Icons.location_on, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 2: To Location
                      FlatInput(
                        label: 'To Location',
                        hint: 'Delivery city',
                        controller: _toController,
                        prefixIcon: const Icon(Icons.location_on, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 3: Material Type
                      FlatDropdown<String>(
                        label: 'Material Type',
                        hint: 'Select material',
                        value: _selectedMaterial,
                        items: [
                          'Steel',
                          'Cement',
                          'Coal',
                          'Grains',
                          'Electronics',
                          'Furniture',
                          'Other',
                        ].map((material) {
                          return DropdownMenuItem(
                            value: material,
                            child: Text(material),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMaterial = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select material type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 4: Truck Type
                      FlatDropdown<String>(
                        label: 'Truck Type',
                        hint: 'Select truck type',
                        value: _selectedTruckType,
                        items: [
                          '32 Ft Trailer',
                          '20 Ft Container',
                          '40 Ft Container',
                          'Open Body',
                          'Tanker',
                          'Refrigerated',
                        ].map((truck) {
                          return DropdownMenuItem(
                            value: truck,
                            child: Text(truck),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTruckType = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select truck type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 5: Weight
                      FlatInput(
                        label: 'Weight (tons)',
                        hint: 'e.g., 20',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.scale, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Optional: Price (not counted in max 5)
                      FlatInput(
                        label: 'Offered Price (Optional)',
                        hint: '₹ 45,000',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                      ),
                      const SizedBox(height: 24),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          border: Border.all(color: AppColors.info),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your load will be visible to all truckers. You can add more details after posting.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom CTA
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
                text: 'Post Load',
                icon: Icons.check,
                onPressed: _submitLoad,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

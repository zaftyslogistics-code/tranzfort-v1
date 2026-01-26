/// Post Load Screen - Single Page (MVP 2.0)
/// 
/// Combines the old step1 and step2 into a single scrollable form.
/// Features: truck type chips, material selector, pricing with advance %.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/truck_categories.dart';
import '../../../../core/constants/material_types.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/truck_type_chip.dart';
import '../../../../shared/widgets/truck_type_sheet.dart';
import '../../../../shared/widgets/material_type_selector.dart';
import '../../../../shared/widgets/price_display.dart';
import '../../../../shared/models/truck_type.dart' as models;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/load.dart';
import '../providers/loads_provider.dart';
import '../widgets/location_input.dart';

class PostLoadScreen extends ConsumerStatefulWidget {
  final Load? existingLoad;
  final String onSuccessRoute;
  final bool showBottomNavigation;
  final bool forceSuperLoad;

  const PostLoadScreen({
    super.key,
    this.existingLoad,
    this.onSuccessRoute = '/my-loads',
    this.showBottomNavigation = true,
    this.forceSuperLoad = false,
  });

  @override
  ConsumerState<PostLoadScreen> createState() => _PostLoadScreenState();
}

class _PostLoadScreenState extends ConsumerState<PostLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Route
  final _fromLocationController = TextEditingController();
  final _fromCityController = TextEditingController();
  final _fromStateController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _toCityController = TextEditingController();
  final _toStateController = TextEditingController();
  double? _fromLat;
  double? _fromLng;
  double? _toLat;
  double? _toLng;

  // Cargo
  String? _selectedMaterialId;
  String? _customMaterialName;
  final _weightController = TextEditingController();

  // Truck
  TruckCategoryId? _selectedTruckCategory;
  models.TruckType? _selectedTruckSpecs;

  // Pricing
  PriceType _priceType = PriceType.negotiable;
  final _ratePerTonController = TextEditingController();
  final _fixedPriceController = TextEditingController();
  int _advancePercent = 70;

  // Schedule & Notes
  DateTime? _loadingDate;
  final _notesController = TextEditingController();
  bool _allowCall = true;
  bool _allowChat = true;

  bool _isSubmitting = false;
  bool get _isEdit => widget.existingLoad != null;

  @override
  void initState() {
    super.initState();
    _initFromExistingLoad();
  }

  void _initFromExistingLoad() {
    final load = widget.existingLoad;
    if (load == null) return;

    _fromLocationController.text = load.fromLocation;
    _fromCityController.text = load.fromCity;
    _fromStateController.text = load.fromState ?? '';
    _toLocationController.text = load.toLocation;
    _toCityController.text = load.toCity;
    _toStateController.text = load.toState ?? '';
    _selectedMaterialId = load.loadType;
    _weightController.text = load.weight?.toStringAsFixed(0) ?? '';
    _loadingDate = load.loadingDate;
    _notesController.text = load.notes ?? '';
    _allowCall = load.contactPreferencesCall;
    _allowChat = load.contactPreferencesChat;

    // Parse price type from existing load
    if (load.priceType == 'per_ton') {
      _priceType = PriceType.perTon;
      _ratePerTonController.text = load.ratePerTon?.toString() ?? '';
    } else if (load.priceType == 'fixed') {
      _priceType = PriceType.fixed;
      _fixedPriceController.text = load.price?.toString() ?? '';
    } else {
      _priceType = PriceType.negotiable;
    }
    _advancePercent = load.advancePercent;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fromLocationController.dispose();
    _fromCityController.dispose();
    _fromStateController.dispose();
    _toLocationController.dispose();
    _toCityController.dispose();
    _toStateController.dispose();
    _weightController.dispose();
    _ratePerTonController.dispose();
    _fixedPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter weight';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Enter valid weight';
    }
    return null;
  }

  Future<void> _pickLoadingDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _loadingDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (selected != null) {
      setState(() => _loadingDate = selected);
    }
  }

  void _showTruckTypeSheet(TruckCategoryId categoryId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TruckTypeSheet(
        categoryId: categoryId,
        currentSelection: _selectedTruckSpecs,
        onApply: (truckType) {
          setState(() {
            _selectedTruckCategory = categoryId;
            _selectedTruckSpecs = truckType;
          });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _selectedTruckSpecs = models.TruckType.fromCategory(categoryId);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _submitLoad() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate selections
    if (_selectedMaterialId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select material type')),
      );
      return;
    }

    if (_selectedTruckCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select truck type')),
      );
      return;
    }

    // Validate same from/to
    if (_fromCityController.text.trim().toLowerCase() ==
        _toCityController.text.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading and unloading points cannot be same'),
        ),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    // Build truck type string
    final truckTypeStr = _selectedTruckSpecs?.fullDisplay ??
        getTruckCategoryById(_selectedTruckCategory!)?.name ??
        _selectedTruckCategory!.name;

    // Get material name
    String materialName = _selectedMaterialId!;
    if (_selectedMaterialId == 'other' && _customMaterialName != null) {
      materialName = _customMaterialName!;
    } else {
      final material = getMaterialTypeById(_selectedMaterialId!);
      if (material != null) materialName = material.name;
    }

    // Calculate price based on type
    double? price;
    double? ratePerTon;
    if (_priceType == PriceType.perTon) {
      ratePerTon = double.tryParse(_ratePerTonController.text);
      final weight = double.tryParse(_weightController.text);
      if (ratePerTon != null && weight != null) {
        price = ratePerTon * weight;
      }
    } else if (_priceType == PriceType.fixed) {
      price = double.tryParse(_fixedPriceController.text);
    }

    final payload = {
      'supplier_id': user.id,
      'from_location': _fromLocationController.text.trim(),
      'from_city': _fromCityController.text.trim(),
      'from_state': _fromStateController.text.trim().isEmpty
          ? null
          : _fromStateController.text.trim(),
      'from_lat': _fromLat,
      'from_lng': _fromLng,
      'to_location': _toLocationController.text.trim(),
      'to_city': _toCityController.text.trim(),
      'to_state': _toStateController.text.trim().isEmpty
          ? null
          : _toStateController.text.trim(),
      'to_lat': _toLat,
      'to_lng': _toLng,
      'load_type': materialName,
      'truck_type_required': truckTypeStr,
      'weight': double.tryParse(_weightController.text),
      'price': price,
      'price_type': _priceType.value,
      'rate_per_ton': ratePerTon,
      'advance_required': _priceType != PriceType.negotiable,
      'advance_percent': _advancePercent,
      'loading_date': _loadingDate?.toIso8601String(),
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'contact_preferences_call': _allowCall,
      'contact_preferences_chat': _allowChat,
      if (widget.forceSuperLoad) 'is_super_load': true,
      if (widget.forceSuperLoad) 'posted_by_admin_id': user.id,
    };

    final loadsNotifier = ref.read(loadsNotifierProvider.notifier);
    bool success;

    if (_isEdit) {
      success = await loadsNotifier.updateLoad(widget.existingLoad!.id, payload);
    } else {
      success = await loadsNotifier.createLoad(payload);
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Load updated successfully'
              : 'Load posted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(widget.onSuccessRoute);
    } else if (mounted) {
      final error = ref.read(loadsNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to post load'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Load' : 'Post New Load'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              // ROUTE SECTION
              _buildSectionHeader('Route', Icons.route),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      _buildLocationRow(
                        label: 'Loading Point',
                        locationController: _fromLocationController,
                        cityController: _fromCityController,
                        stateController: _fromStateController,
                        dotColor: AppColors.success,
                        onLocationSelected: (lat, lng) {
                          _fromLat = lat;
                          _fromLng = lng;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      _buildLocationRow(
                        label: 'Unloading Point',
                        locationController: _toLocationController,
                        cityController: _toCityController,
                        stateController: _toStateController,
                        dotColor: AppColors.error,
                        onLocationSelected: (lat, lng) {
                          _toLat = lat;
                          _toLng = lng;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // CARGO SECTION
              _buildSectionHeader('Cargo', Icons.inventory_2),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Material Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      MaterialTypeSelector(
                        selectedMaterialId: _selectedMaterialId,
                        customMaterialName: _customMaterialName,
                        onMaterialSelected: (id) {
                          setState(() => _selectedMaterialId = id);
                        },
                        onCustomMaterialEntered: (name) {
                          setState(() => _customMaterialName = name);
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight (tons)',
                          hintText: 'e.g., 30',
                          prefixIcon: Icon(Icons.scale),
                        ),
                        validator: _validateWeight,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // TRUCK TYPE SECTION
              _buildSectionHeader('Truck Required', Icons.local_shipping),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select truck type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      Wrap(
                        spacing: AppDimensions.paddingSmall,
                        runSpacing: AppDimensions.paddingSmall,
                        children: kTruckCategories.map((category) {
                          final isSelected = _selectedTruckCategory == category.id;
                          return TruckTypeChip(
                            category: category,
                            isSelected: isSelected,
                            compact: true,
                            onTap: () {
                              setState(() {
                                _selectedTruckCategory = category.id;
                                _selectedTruckSpecs =
                                    models.TruckType.fromCategory(category.id);
                              });
                              // Show bottom sheet for specs
                              if (category.availableSubOptions.length > 1) {
                                _showTruckTypeSheet(category.id);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedTruckSpecs != null) ...[
                        const SizedBox(height: AppDimensions.paddingMedium),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSmall,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedTruckSpecs!.fullDisplay,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showTruckTypeSheet(
                                  _selectedTruckCategory!,
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // PRICING SECTION
              _buildSectionHeader('Payment', Icons.payments),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: PriceInputSection(
                    priceType: _priceType,
                    ratePerTon: double.tryParse(_ratePerTonController.text),
                    fixedPrice: double.tryParse(_fixedPriceController.text),
                    advancePercent: _advancePercent,
                    weightTons: double.tryParse(_weightController.text),
                    onPriceTypeChanged: (type) {
                      setState(() => _priceType = type);
                    },
                    onRateChanged: (rate) {
                      _ratePerTonController.text = rate?.toString() ?? '';
                      setState(() {});
                    },
                    onFixedPriceChanged: (price) {
                      _fixedPriceController.text = price?.toString() ?? '';
                      setState(() {});
                    },
                    onAdvancePercentChanged: (percent) {
                      setState(() => _advancePercent = percent);
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // SCHEDULE SECTION
              _buildSectionHeader('Schedule', Icons.calendar_today),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loading Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSmall),
                      GestureDetector(
                        onTap: _pickLoadingDate,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: AppColors.borderLight.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _loadingDate != null
                                    ? '${_loadingDate!.day}/${_loadingDate!.month}/${_loadingDate!.year}'
                                    : 'Select loading date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _loadingDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes (Optional)',
                          hintText: 'Any special requirements...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // CONTACT PREFERENCES
              _buildSectionHeader('Contact Preferences', Icons.contact_phone),
              GlassmorphicCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Allow calls'),
                        subtitle: const Text('Truckers can call you directly'),
                        value: _allowCall,
                        onChanged: (v) => setState(() => _allowCall = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Allow chat'),
                        subtitle: const Text('Truckers can message you'),
                        value: _allowChat,
                        onChanged: (v) => setState(() => _allowChat = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXLarge),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEdit ? 'UPDATE LOAD' : 'POST LOAD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXLarge),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? const AppBottomNavigation(currentIndex: 0)
          : null,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required String label,
    required TextEditingController locationController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    required Color dotColor,
    required Function(double?, double?) onLocationSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          controller: cityController,
          decoration: InputDecoration(
            hintText: 'City',
            prefixIcon: const Icon(Icons.location_city),
          ),
          validator: (v) => _validateRequired(v, 'city'),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: stateController,
                decoration: const InputDecoration(
                  hintText: 'State (Optional)',
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Area/Landmark',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/loads_provider.dart';
import '../widgets/load_form_field.dart';
import '../widgets/location_input.dart';
import '../../domain/entities/load.dart';
import '../../domain/entities/truck_type.dart' as domain;
import '../../domain/entities/material_type.dart' as material;

class PostLoadStep1Screen extends ConsumerStatefulWidget {
  final Load? existingLoad;

  const PostLoadStep1Screen({
    super.key,
    this.existingLoad,
  });

  @override
  ConsumerState<PostLoadStep1Screen> createState() =>
      _PostLoadStep1ScreenState();
}

class _PostLoadStep1ScreenState extends ConsumerState<PostLoadStep1Screen> {
  final _formKey = GlobalKey<FormState>();

  final _fromLocationController = TextEditingController();
  final _fromCityController = TextEditingController();
  final _fromStateController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _toCityController = TextEditingController();
  final _toStateController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedMaterial;
  String? _selectedTruckType;
  bool get _isEdit => widget.existingLoad != null;

  @override
  void initState() {
    super.initState();
    final load = widget.existingLoad;
    if (load != null) {
      _fromLocationController.text = load.fromLocation;
      _fromCityController.text = load.fromCity;
      _fromStateController.text = load.fromState ?? '';
      _toLocationController.text = load.toLocation;
      _toCityController.text = load.toCity;
      _toStateController.text = load.toState ?? '';
      _selectedMaterial = load.loadType;
      _selectedTruckType = load.truckTypeRequired;
      _weightController.text = load.weight?.toStringAsFixed(0) ?? '';
    }
  }

  @override
  void dispose() {
    _fromLocationController.dispose();
    _fromCityController.dispose();
    _fromStateController.dispose();
    _toLocationController.dispose();
    _toCityController.dispose();
    _toStateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMaterial == null || _selectedTruckType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select material and truck type'),
        ),
      );
      return;
    }

    final loadData = {
      'fromLocation': _fromLocationController.text,
      'fromCity': _fromCityController.text,
      'fromState':
          _fromStateController.text.isEmpty ? null : _fromStateController.text,
      'toLocation': _toLocationController.text,
      'toCity': _toCityController.text,
      'toState':
          _toStateController.text.isEmpty ? null : _toStateController.text,
      'loadType': _selectedMaterial,
      'truckTypeRequired': _selectedTruckType,
      'weight': double.tryParse(_weightController.text),
    };

    context.push(
      '/post-load-step2',
      extra: {
        'loadData': loadData,
        'existingLoad': widget.existingLoad,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final truckTypes = ref.watch(truckTypesProvider);
    final materialTypes = ref.watch(materialTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Load - Step 1' : 'Post Load - Step 1'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    AppColors.secondaryBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                children: [
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GradientText(
                          _isEdit ? 'Edit Load - Step 1' : 'Post Load - Step 1',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LocationInput(
                          label: 'Pickup Location',
                          locationController: _fromLocationController,
                          cityController: _fromCityController,
                          stateController: _fromStateController,
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        LocationInput(
                          label: 'Drop Location',
                          locationController: _toLocationController,
                          cityController: _toCityController,
                          stateController: _toStateController,
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        Text(
                          'Material Type',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        materialTypes.when(
                          data: (types) {
                            // Use enhanced Indian material types
                            final materialList = types.isNotEmpty
                                ? types
                                : [
                                    const material.MaterialType(
                                        id: 1,
                                        name: 'Agriculture - Grains',
                                        category: 'Agriculture',
                                        displayOrder: 1),
                                    const material.MaterialType(
                                        id: 2,
                                        name: 'Agriculture - Vegetables',
                                        category: 'Agriculture',
                                        displayOrder: 2),
                                    const material.MaterialType(
                                        id: 3,
                                        name: 'FMCG',
                                        category: 'FMCG',
                                        displayOrder: 3),
                                    const material.MaterialType(
                                        id: 4,
                                        name: 'Building Materials',
                                        category: 'Building Materials',
                                        displayOrder: 4),
                                    const material.MaterialType(
                                        id: 5,
                                        name: 'Textiles',
                                        category: 'Textiles',
                                        displayOrder: 5),
                                    const material.MaterialType(
                                        id: 6,
                                        name: 'Electronics',
                                        category: 'Electronics',
                                        displayOrder: 6),
                                    const material.MaterialType(
                                        id: 7,
                                        name: 'Machinery',
                                        category: 'Machinery',
                                        displayOrder: 7),
                                    const material.MaterialType(
                                        id: 8,
                                        name: 'Chemicals',
                                        category: 'Chemicals',
                                        displayOrder: 8),
                                    const material.MaterialType(
                                        id: 9,
                                        name: 'Furniture',
                                        category: 'Furniture',
                                        displayOrder: 9),
                                    const material.MaterialType(
                                        id: 10,
                                        name: 'Other',
                                        category: 'Other',
                                        displayOrder: 10),
                                  ];
                            final selectedMaterial = materialList
                                    .any((t) => t.name == _selectedMaterial)
                                ? _selectedMaterial
                                : null;
                            return DropdownButtonFormField<String>(
                              initialValue: selectedMaterial,
                              isExpanded: true,
                              dropdownColor: AppColors.darkSurface,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.textPrimary),
                              items: materialList
                                  .map<DropdownMenuItem<String>>(
                                    (type) => DropdownMenuItem(
                                      value: type.name,
                                      child: Text(
                                        type.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: AppColors.textPrimary),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedMaterial = value),
                              decoration: const InputDecoration(
                                  hintText: 'Select material'),
                              validator: (value) => Validators.validateRequired(
                                  value, 'material'),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) {
                            final materialList = [
                              const material.MaterialType(
                                  id: 1,
                                  name: 'Agriculture - Grains',
                                  category: 'Agriculture',
                                  displayOrder: 1),
                              const material.MaterialType(
                                  id: 2,
                                  name: 'Agriculture - Vegetables',
                                  category: 'Agriculture',
                                  displayOrder: 2),
                              const material.MaterialType(
                                  id: 3,
                                  name: 'FMCG',
                                  category: 'FMCG',
                                  displayOrder: 3),
                              const material.MaterialType(
                                  id: 4,
                                  name: 'Building Materials',
                                  category: 'Building Materials',
                                  displayOrder: 4),
                              const material.MaterialType(
                                  id: 5,
                                  name: 'Textiles',
                                  category: 'Textiles',
                                  displayOrder: 5),
                              const material.MaterialType(
                                  id: 6,
                                  name: 'Electronics',
                                  category: 'Electronics',
                                  displayOrder: 6),
                              const material.MaterialType(
                                  id: 7,
                                  name: 'Machinery',
                                  category: 'Machinery',
                                  displayOrder: 7),
                              const material.MaterialType(
                                  id: 8,
                                  name: 'Chemicals',
                                  category: 'Chemicals',
                                  displayOrder: 8),
                              const material.MaterialType(
                                  id: 9,
                                  name: 'Furniture',
                                  category: 'Furniture',
                                  displayOrder: 9),
                              const material.MaterialType(
                                  id: 10,
                                  name: 'Other',
                                  category: 'Other',
                                  displayOrder: 10),
                            ];
                            final selectedMaterial = materialList
                                    .any((t) => t.name == _selectedMaterial)
                                ? _selectedMaterial
                                : null;

                            return DropdownButtonFormField<String>(
                              initialValue: selectedMaterial,
                              isExpanded: true,
                              dropdownColor: AppColors.darkSurface,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.textPrimary),
                              items: materialList
                                  .map<DropdownMenuItem<String>>(
                                    (type) => DropdownMenuItem(
                                      value: type.name,
                                      child: Text(
                                        type.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: AppColors.textPrimary),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedMaterial = value),
                              decoration: const InputDecoration(
                                  hintText: 'Select material'),
                              validator: (value) => Validators.validateRequired(
                                  value, 'material'),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        Text(
                          'Truck Type Required',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        truckTypes.when(
                          data: (types) {
                            final truckList = types.isNotEmpty
                                ? types
                                : [
                                    domain.TruckType(
                                        id: 1,
                                        name: 'Small Truck (4-6 Tyres)',
                                        category: 'Small',
                                        displayOrder: 1),
                                    domain.TruckType(
                                        id: 2,
                                        name: 'Medium Truck (10-12 Tyres)',
                                        category: 'Medium',
                                        displayOrder: 2),
                                    domain.TruckType(
                                        id: 3,
                                        name: 'Heavy Truck (14-16 Tyres)',
                                        category: 'Heavy',
                                        displayOrder: 3),
                                    domain.TruckType(
                                        id: 4,
                                        name: 'Super Heavy (18+ Tyres)',
                                        category: 'Super Heavy',
                                        displayOrder: 4),
                                    domain.TruckType(
                                        id: 5,
                                        name: 'Container Truck',
                                        category: 'Container',
                                        displayOrder: 5),
                                    domain.TruckType(
                                        id: 6,
                                        name: 'Flatbed Truck',
                                        category: 'Flatbed',
                                        displayOrder: 6),
                                    domain.TruckType(
                                        id: 7,
                                        name: 'Tanker Truck',
                                        category: 'Tanker',
                                        displayOrder: 7),
                                    domain.TruckType(
                                        id: 8,
                                        name: 'Specialized Truck',
                                        category: 'Specialized',
                                        displayOrder: 8),
                                  ];
                            final selectedTruckType = truckList
                                    .any((t) => t.name == _selectedTruckType)
                                ? _selectedTruckType
                                : null;
                            return DropdownButtonFormField<String>(
                              initialValue: selectedTruckType,
                              isExpanded: true,
                              dropdownColor: AppColors.darkSurface,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.textPrimary),
                              items: truckList
                                  .map<DropdownMenuItem<String>>(
                                    (type) => DropdownMenuItem(
                                      value: type.name,
                                      child: Text(
                                        type.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                color: AppColors.textPrimary),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedTruckType = value),
                              decoration: const InputDecoration(
                                  hintText: 'Select truck type'),
                              validator: (value) => Validators.validateRequired(
                                  value, 'truck type'),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Text(
                            'Error: $error',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        LoadFormField(
                          label: 'Weight (tons)',
                          controller: _weightController,
                          hint: 'Optional',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        ElevatedButton(
                          onPressed: _nextStep,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((0.35 * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

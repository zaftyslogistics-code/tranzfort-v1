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

  double? _fromLat;
  double? _fromLng;
  double? _toLat;
  double? _toLng;

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
      'fromLocation': _fromLocationController.text.trim(),
      'fromCity': _fromCityController.text.trim(),
      'fromState': _fromStateController.text.trim(),
      'fromLat': _fromLat,
      'fromLng': _fromLng,
      'toLocation': _toLocationController.text.trim(),
      'toCity': _toCityController.text.trim(),
      'toState': _toStateController.text.trim(),
      'toLat': _toLat,
      'toLng': _toLng,
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
                          onCoordinates: (lat, lng) {
                            _fromLat = lat;
                            _fromLng = lng;
                          },
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        LocationInput(
                          label: 'Drop Location',
                          locationController: _toLocationController,
                          cityController: _toCityController,
                          stateController: _toStateController,
                          onCoordinates: (lat, lng) {
                            _toLat = lat;
                            _toLng = lng;
                          },
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
                                        name: 'Agriculture',
                                        category: 'Agriculture',
                                        displayOrder: 1),
                                    const material.MaterialType(
                                        id: 2,
                                        name:
                                            'Construction / Building Materials',
                                        category: 'Construction',
                                        displayOrder: 2),
                                    const material.MaterialType(
                                        id: 3,
                                        name: 'FMCG / Consumer Goods',
                                        category: 'FMCG',
                                        displayOrder: 3),
                                    const material.MaterialType(
                                        id: 4,
                                        name: 'Industrial / Machinery',
                                        category: 'Industrial',
                                        displayOrder: 4),
                                    const material.MaterialType(
                                        id: 5,
                                        name: 'Other',
                                        category: 'Other',
                                        displayOrder: 5),
                                  ];

                            final effectiveMaterialList =
                                materialList.toList(growable: true);
                            if (_selectedMaterial != null &&
                                _selectedMaterial!.isNotEmpty &&
                                !effectiveMaterialList
                                    .any((t) => t.name == _selectedMaterial)) {
                              effectiveMaterialList.insert(
                                0,
                                material.MaterialType(
                                  id: 0,
                                  name: _selectedMaterial!,
                                  category: 'Legacy',
                                  displayOrder: 0,
                                ),
                              );
                            }

                            final selectedMaterial = effectiveMaterialList
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
                              items: effectiveMaterialList
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
                                  name: 'Agriculture',
                                  category: 'Agriculture',
                                  displayOrder: 1),
                              const material.MaterialType(
                                  id: 2,
                                  name: 'Construction / Building Materials',
                                  category: 'Construction',
                                  displayOrder: 2),
                              const material.MaterialType(
                                  id: 3,
                                  name: 'FMCG / Consumer Goods',
                                  category: 'FMCG',
                                  displayOrder: 3),
                              const material.MaterialType(
                                  id: 4,
                                  name: 'Industrial / Machinery',
                                  category: 'Industrial',
                                  displayOrder: 4),
                              const material.MaterialType(
                                  id: 5,
                                  name: 'Other',
                                  category: 'Other',
                                  displayOrder: 5),
                            ];

                            final effectiveMaterialList =
                                materialList.toList(growable: true);
                            if (_selectedMaterial != null &&
                                _selectedMaterial!.isNotEmpty &&
                                !effectiveMaterialList
                                    .any((t) => t.name == _selectedMaterial)) {
                              effectiveMaterialList.insert(
                                0,
                                material.MaterialType(
                                  id: 0,
                                  name: _selectedMaterial!,
                                  category: 'Legacy',
                                  displayOrder: 0,
                                ),
                              );
                            }
                            final selectedMaterial = effectiveMaterialList
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
                              items: effectiveMaterialList
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
                                        name: 'Open Body',
                                        category: 'Body Type',
                                        displayOrder: 1),
                                    domain.TruckType(
                                        id: 2,
                                        name: 'Flat Body',
                                        category: 'Body Type',
                                        displayOrder: 2),
                                    domain.TruckType(
                                        id: 3,
                                        name: 'Bulker',
                                        category: 'Body Type',
                                        displayOrder: 3),
                                    domain.TruckType(
                                        id: 4,
                                        name: 'Container',
                                        category: 'Body Type',
                                        displayOrder: 4),
                                  ];

                            final effectiveTruckList =
                                truckList.toList(growable: true);
                            if (_selectedTruckType != null &&
                                _selectedTruckType!.isNotEmpty &&
                                !effectiveTruckList
                                    .any((t) => t.name == _selectedTruckType)) {
                              effectiveTruckList.insert(
                                0,
                                domain.TruckType(
                                  id: 0,
                                  name: _selectedTruckType!,
                                  category: 'Legacy',
                                  displayOrder: 0,
                                ),
                              );
                            }

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
                              items: effectiveTruckList
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

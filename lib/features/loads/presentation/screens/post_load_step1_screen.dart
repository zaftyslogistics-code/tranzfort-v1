import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../domain/entities/load.dart';
import '../providers/loads_provider.dart';
import '../widgets/location_input.dart';
import '../widgets/load_form_field.dart';

class PostLoadStep1Screen extends ConsumerStatefulWidget {
  final Load? existingLoad;

  const PostLoadStep1Screen({
    super.key,
    this.existingLoad,
  });

  @override
  ConsumerState<PostLoadStep1Screen> createState() => _PostLoadStep1ScreenState();
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
      'fromState': _fromStateController.text.isEmpty ? null : _fromStateController.text,
      'toLocation': _toLocationController.text,
      'toCity': _toCityController.text,
      'toState': _toStateController.text.isEmpty ? null : _toStateController.text,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        materialTypes.when(
                          data: (types) => DropdownButtonFormField<String>(
                            initialValue: _selectedMaterial,
                            dropdownColor: AppColors.darkSurface,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textPrimary),
                            items: types
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type.name,
                                    child: Text(
                                      type.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: AppColors.textPrimary),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedMaterial = value),
                            decoration:
                                const InputDecoration(hintText: 'Select material'),
                            validator: (value) =>
                                Validators.validateRequired(value, 'material'),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Text(
                            'Failed to load materials',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        Text(
                          'Truck Type Required',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        truckTypes.when(
                          data: (types) => DropdownButtonFormField<String>(
                            initialValue: _selectedTruckType,
                            dropdownColor: AppColors.darkSurface,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textPrimary),
                            items: types
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type.name,
                                    child: Text(
                                      type.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: AppColors.textPrimary),
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
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Text(
                            'Failed to load truck types',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
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

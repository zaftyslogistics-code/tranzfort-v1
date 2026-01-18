import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/loads_provider.dart';

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  String? _selectedTruckType;
  String? _selectedMaterial;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters applied (mock)')),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTruckType = null;
      _selectedMaterial = null;
      _fromController.clear();
      _toController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final truckTypes = ref.watch(truckTypesProvider);
    final materialTypes = ref.watch(materialTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientText(
                      'Filters',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    TextField(
                      controller: _fromController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                      decoration: const InputDecoration(
                        labelText: 'From Location',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    TextField(
                      controller: _toController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                      decoration: const InputDecoration(
                        labelText: 'To Location',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      'Truck Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    truckTypes.when(
                      data: (types) => DropdownButtonFormField<String>(
                        initialValue: _selectedTruckType,
                        items: types
                            .map((type) => DropdownMenuItem(
                                  value: type.name,
                                  child: Text(type.name),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTruckType = value),
                        decoration:
                            const InputDecoration(hintText: 'Select truck type'),
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
                        items: types
                            .map((type) => DropdownMenuItem(
                                  value: type.name,
                                  child: Text(type.name),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedMaterial = value),
                        decoration:
                            const InputDecoration(hintText: 'Select material'),
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
                    const SizedBox(height: AppDimensions.xl),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
            ],
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

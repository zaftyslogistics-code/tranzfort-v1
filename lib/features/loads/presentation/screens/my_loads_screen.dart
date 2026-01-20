import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../providers/loads_provider.dart';
import '../widgets/load_card.dart';
import '../widgets/empty_loads_state.dart';

class MyLoadsScreen extends ConsumerStatefulWidget {
  const MyLoadsScreen({super.key});

  @override
  ConsumerState<MyLoadsScreen> createState() => _MyLoadsScreenState();
}

class _MyLoadsScreenState extends ConsumerState<MyLoadsScreen> {
  String _selectedTab = 'active';

  @override
  void initState() {
    super.initState();
    // Initialize loads data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadsNotifierProvider.notifier).fetchLoads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);
    final loads = loadsState.loads;

    // Filter loads based on selected tab
    List filteredLoads;
    switch (_selectedTab) {
      case 'active':
        filteredLoads = loads.where((load) => !load.isExpired).toList();
        break;
      case 'expired':
        filteredLoads = loads.where((load) => load.isExpired).toList();
        break;
      case 'all':
      default:
        filteredLoads = loads;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push('/filters'),
          ),
        ],
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
            child: _GlowOrb(size: 280, color: AppColors.cyanGlowStrong),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(size: 320, color: AppColors.primary),
          ),
          Column(
            children: [
              // Tabs
              Container(
                margin: const EdgeInsets.all(AppDimensions.lg),
                child: GlassmorphicCard(
                  backgroundColor: AppColors.glassSurfaceStrong,
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  child: Row(
                    children: ['active', 'expired', 'all'].map((tab) {
                      final isSelected = _selectedTab == tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tab[0].toUpperCase() + tab.substring(1),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Loads List
              Expanded(
                child: loadsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : loadsState.error != null
                        ? Center(
                            child: Text(
                              'Error: ${loadsState.error}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.danger,
                                  ),
                            ),
                          )
                        : filteredLoads.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(AppDimensions.lg),
                                child: EmptyLoadsState(
                                  message: _selectedTab == 'active'
                                      ? 'No active loads'
                                      : _selectedTab == 'expired'
                                          ? 'No expired loads'
                                          : 'No loads found',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                                itemCount: filteredLoads.length,
                                itemBuilder: (context, index) {
                                  final load = filteredLoads[index];
                                  return LoadCard(
                                    load: load,
                                    showStatus: true,
                                    onTap: () => context.push('/load-detail-supplier', extra: load.id),
                                  );
                                },
                              ),
              ),
            ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/loads_provider.dart';
import '../widgets/load_card.dart';
import '../widgets/empty_loads_state.dart';

class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState
    extends ConsumerState<SupplierDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchLoads();
    });
  }

  Future<void> _fetchLoads() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;
    await ref
        .read(loadsNotifierProvider.notifier)
        .fetchLoads(supplierId: user.id);
  }

  List<dynamic> _filterLoads(String tab, List<dynamic> loads) {
    switch (tab) {
      case 'Active':
        return loads.where((load) => load.isActive).toList();
      case 'Expired':
        return loads.where((load) => load.isExpired).toList();
      default:
        return loads;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Loads'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Expired'),
              Tab(text: 'All'),
            ],
          ),
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
            TabBarView(
              children: ['Active', 'Expired', 'All'].map((tab) {
                final filteredLoads = _filterLoads(tab, loadsState.loads);

                if (loadsState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredLoads.isEmpty) {
                  return EmptyLoadsState(
                    message: 'No $tab loads yet',
                    actionLabel: 'Post a Load',
                    onAction: () => context.push('/post-load-step1'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchLoads,
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    children: [
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GradientText(
                              'My Loads',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              tab,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      ...filteredLoads.map(
                        (load) => LoadCard(
                          load: load,
                          showStatus: true,
                          onTap: () =>
                              context.push('/load-detail-supplier', extra: load.id),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/post-load-step1'),
          label: const Text('Post Load'),
          icon: const Icon(Icons.add),
        ),
        bottomNavigationBar: const AppBottomNavigation(),
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

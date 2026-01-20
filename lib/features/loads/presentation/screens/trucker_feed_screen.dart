import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/ad_impression_tracker.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/native_ad_widget.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/loads_provider.dart';
import '../widgets/filter_chip_group.dart';
import '../widgets/load_card.dart';
import '../widgets/empty_loads_state.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/glow_orb.dart';

class TruckerFeedScreen extends ConsumerStatefulWidget {
  const TruckerFeedScreen({super.key});

  @override
  ConsumerState<TruckerFeedScreen> createState() => _TruckerFeedScreenState();
}

class _TruckerFeedScreenState extends ConsumerState<TruckerFeedScreen> {
  final _searchController = TextEditingController();
  String _filter = 'Active';
  late final AdImpressionTracker _adImpressionTracker;

  @override
  void initState() {
    super.initState();
    _adImpressionTracker = AdImpressionTracker(Supabase.instance.client);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchLoads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLoads() async {
    final status = _filter == 'Active' ? 'active' : null;
    await ref.read(loadsNotifierProvider.notifier).fetchLoads(status: status);
  }

  List<dynamic> _applyFilters(List<dynamic> loads) {
    var filtered = loads;

    if (_filter == 'Active') {
      filtered = filtered.where((load) => load.isActive).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((load) {
        return load.fromLocation.toLowerCase().contains(query) ||
            load.toLocation.toLowerCase().contains(query) ||
            load.fromCity.toLowerCase().contains(query) ||
            load.toCity.toLowerCase().contains(query) ||
            load.truckTypeRequired.toLowerCase().contains(query) ||
            load.loadType.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);
    final filteredLoads = _applyFilters(loadsState.loads);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Loads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push('/filters'),
          ),
        ],
      ),
      body: Stack(
        children: [
          const OfflineBanner(), // Show offline banner at top when offline
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
          ...GlowOrbPresets.getGlowOrbsForScreen('load'),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  AppDimensions.lg,
                  AppDimensions.lg,
                  AppDimensions.sm,
                ),
                child: GlassmorphicCard(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GradientText(
                        'Browse Loads',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by city, truck, material...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      FilterChipGroup(
                        options: const ['Active', 'All'],
                        selected: _filter,
                        onSelected: (value) {
                          setState(() => _filter = value);
                          _fetchLoads();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: loadsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredLoads.isEmpty
                        ? const EmptyLoadsState(
                            message: 'No loads available right now',
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchLoads,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.sm,
                              ),
                              itemCount: filteredLoads.length,
                              itemBuilder: (context, index) {
                                // Show native ad every 5 loads (after 4th, 9th, 14th, etc.)
                                if (index % 5 == 4 && index != filteredLoads.length - 1) {
                                  return NativeAdWidget(
                                    screenName: 'load_feed',
                                    userId: user?.id,
                                    isVerifiedUser: user?.isTruckerVerified ?? false,
                                    impressionTracker: _adImpressionTracker,
                                  );
                                }

                                final load = filteredLoads[index];
                                return LoadCard(
                                  load: load,
                                  onTap: () => context.push(
                                    '/load-detail-trucker',
                                    extra: load.id,
                                  ),
                                );
                              },
                            ),
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

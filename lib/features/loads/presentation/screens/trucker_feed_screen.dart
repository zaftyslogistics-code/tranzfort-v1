import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/services/ad_impression_tracker.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/conditional_ad_widget.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/truck_type_chip_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/loads_provider.dart';
import '../widgets/filter_chip_group.dart';
import '../widgets/load_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/glow_orb.dart';
import '../../../../shared/widgets/role_badge.dart';

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
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLoads() async {
    final status = _filter == 'Active' ? 'active' : null;
    final query = _searchController.text.trim();

    await ref.read(loadsNotifierProvider.notifier).fetchLoads(
          status: status,
          searchQuery: query.isNotEmpty ? query : null,
        );
  }

  // NOTE: We now do server-side filtering, so this local filter is mainly for
  // ensuring the UI state is consistent or for offline fallback if we implemented that logic.
  // But for now, we rely on the provider's loads which are already filtered by the server.
  List<dynamic> _applyFilters(List<dynamic> loads) {
    // We can just return the loads as they are server-filtered now.
    // However, if we want to keep some local instant feedback while typing (debounce needed),
    // we could keep it. But simplest is to just return loads.
    return loads;
  }

  void _onSearchChanged(String value) {
    // Debounce or just search on submit?
    // For now, let's search on submit or with a slight delay.
    // But given the UI has a search icon but no explicit submit button in the field decoration,
    // let's assume we want to search as they type or when they hit enter.
    // The previous implementation did local filtering on change.
    // Let's implement a simple debounce here if we want auto-search.
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchLoads();
    });
  }

  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final loadsState = ref.watch(loadsNotifierProvider);
    final filteredLoads = _applyFilters(loadsState.loads);
    final user = ref.watch(authNotifierProvider).user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Find Loads'),
            const SizedBox(width: AppDimensions.sm),
            const RoleBadge(isSupplier: false),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            icon: Icon(
              themeMode == ThemeMode.system
                  ? Icons.brightness_auto
                  : (themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode),
            ),
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .toggleFromSystem(MediaQuery.platformBrightnessOf(context)),
          ),
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
              decoration: appBackgroundDecoration(context),
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
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) => _fetchLoads(),
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
              // Truck Type Chip Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                ),
                child: TruckTypeChipBar(
                  selection: ref.watch(truckTypeSelectionProvider),
                  onSelectionChanged: (selection) {
                    ref.read(truckTypeSelectionProvider.notifier).state = selection;
                    _fetchLoads();
                  },
                ),
              ),
              Expanded(
                child: loadsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredLoads.isEmpty
                        ? EmptyStateWidget(
                            message: 'No Loads Found',
                            subMessage:
                                'Try adjusting your filters or search query.',
                            icon: Icons.search_off,
                            actionLabel: 'Clear Filters',
                            onAction: () {
                              setState(() {
                                _searchController.clear();
                                _filter = 'All';
                              });
                              _fetchLoads();
                            },
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
                                if (index % 5 == 4 &&
                                    index != filteredLoads.length - 1) {
                                  return ConditionalAdWidget(
                                    screenName: 'load_feed',
                                    userId: user?.id,
                                    isVerifiedUser:
                                        user?.isTruckerVerified ?? false,
                                    impressionTracker: _adImpressionTracker,
                                  );
                                }

                                final load = filteredLoads[index];
                                return LoadCard(
                                  load: load,
                                  showStatus: true,
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

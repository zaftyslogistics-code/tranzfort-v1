import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../providers/saved_searches_provider.dart';

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync = ref.watch(savedSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Searches'),
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'Your Saved Searches',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Save your frequent searches and get notified when matching loads are posted.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              searchesAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return Column(
                    children: items
                        .map(
                          (s) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppDimensions.md),
                            child: GlassmorphicCard(
                              padding:
                                  const EdgeInsets.all(AppDimensions.md),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppDimensions.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.searchName ?? 'Saved Search',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: AppDimensions.xs),
                                        Text(
                                          '${s.fromLocation ?? 'Any'} → ${s.toLocation ?? 'Any'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.sm),
                                  Icon(
                                    s.isAlertEnabled
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: s.isAlertEnabled
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => GlassmorphicCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Text(
                    e.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to create saved search screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create saved search - Coming soon'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Search'),
        backgroundColor: AppColors.primary,
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'No saved searches yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Create your first saved search to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

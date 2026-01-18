import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../providers/ratings_provider.dart';

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(myRatingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ratings')),
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
                      'Your Ratings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'This shows ratings associated with your account.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              ratingsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return GlassmorphicCard(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 64,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'No ratings yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: items
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.md),
                            child: GlassmorphicCard(
                              padding: const EdgeInsets.all(AppDimensions.md),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.accent),
                                  const SizedBox(width: AppDimensions.sm),
                                  Text(
                                    '${r.ratingValue}/5',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: AppDimensions.md),
                                  Expanded(
                                    child: Text(
                                      r.feedbackText ?? 'No feedback',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.textSecondary),
                                    ),
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
    );
  }
}

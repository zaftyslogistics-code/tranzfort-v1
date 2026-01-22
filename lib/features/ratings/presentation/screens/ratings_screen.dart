import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../providers/ratings_provider.dart';

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  void _showDisputeDialog(BuildContext context, String ratingId) {
    final descriptionController = TextEditingController();
    String selectedReason = 'Inaccurate Rating';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Rating Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: const [
                DropdownMenuItem(
                    value: 'Inaccurate Rating',
                    child: Text('Inaccurate Rating')),
                DropdownMenuItem(
                    value: 'Fake Review', child: Text('Fake Review')),
                DropdownMenuItem(
                    value: 'Harassment', child: Text('Harassment')),
                DropdownMenuItem(value: 'Spam', child: Text('Spam')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedReason = value;
                }
              },
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Provide details about the issue',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Submit dispute to backend
              // For now, just show success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispute reported successfully')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'No ratings yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
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
                            padding:
                                const EdgeInsets.only(bottom: AppDimensions.md),
                            child: GlassmorphicCard(
                              padding: const EdgeInsets.all(AppDimensions.md),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppColors.accent),
                                  const SizedBox(width: AppDimensions.sm),
                                  Text(
                                    '${r.ratingValue}/5',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
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
                                          ?.copyWith(
                                              color: AppColors.textSecondary),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.report_problem_outlined,
                                        color: AppColors.warning),
                                    onPressed: () =>
                                        _showDisputeDialog(context, r.id),
                                    tooltip: 'Report Issue',
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
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';

class FleetStatsCard extends StatelessWidget {
  const FleetStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      backgroundColor: AppColors.glassSurfaceStrong,
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              GradientText(
                'Fleet Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  'LIVE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Trucks',
                  '12',
                  Icons.local_shipping,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Active',
                  '8',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Expiring Soon',
                  '2',
                  Icons.warning,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // Additional Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Avg Capacity',
                  '18.5t',
                  Icons.fitness_center,
                  AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Utilization',
                  '75%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

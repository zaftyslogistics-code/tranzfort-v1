import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../domain/entities/load.dart';

class LoadCard extends StatelessWidget {
  final Load load;
  final VoidCallback onTap;
  final bool showStatus;

  const LoadCard({
    super.key,
    required this.load,
    required this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppDimensions.md),
          borderRadius: AppDimensions.radiusMd,
          showGlow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.xxs),
                            Expanded(
                              child: Text(
                                load.fromLocationDisplay,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.xxs),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.xxs + 4),
                            Expanded(
                              child: Text(
                                load.toLocationDisplay,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showStatus && load.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withAlpha((0.2 * 255).round()),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(
                          color:
                              AppColors.danger.withAlpha((0.4 * 255).round()),
                        ),
                      ),
                      child: Text(
                        'Expired',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.xs,
                children: [
                  _InfoChip(
                    icon: Icons.local_shipping_outlined,
                    label: load.truckTypeRequired,
                  ),
                  _InfoChip(
                    icon: Icons.inventory_2_outlined,
                    label: load.loadType,
                  ),
                  if (load.hasWeight)
                    _InfoChip(
                      icon: Icons.scale_outlined,
                      label: Formatters.formatWeight(load.weight!),
                    ),
                  if (load.hasPrice)
                    _InfoChip(
                      icon: Icons.currency_rupee,
                      label: Formatters.formatCurrency(load.price!),
                      color: AppColors.success,
                    ),
                ],
              ),
              if (load.loadingDate != null) ...[
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.xxs),
                    Text(
                      'Loading: ${Formatters.formatDate(load.loadingDate!)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/free_badge.dart';
import '../../domain/entities/truck.dart';

class TruckCard extends StatelessWidget {
  final Truck truck;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TruckCard({
    super.key,
    required this.truck,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(truck.statusText);
    final statusIcon = _getStatusIcon(truck.statusText);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GlassmorphicCard(
        backgroundColor: AppColors.glassSurfaceStrong,
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with truck number and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truck.truckNumber,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          truck.truckType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: statusColor.withAlpha((0.35 * 255).round()),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          truck.statusText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              
              // Truck specifications
              Row(
                children: [
                  _buildSpecItem('Capacity', '${truck.capacity} tons', Icons.local_shipping),
                  const SizedBox(width: AppDimensions.lg),
                  _buildSpecItem('RC', truck.rcExpiryDate != null 
                      ? 'Valid' 
                      : 'Not Uploaded', Icons.description),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              
              // Document Status
              _buildDocumentStatus(context),
              
              const SizedBox(height: AppDimensions.md),
              
              // Action Buttons
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.ghost,
                      onPressed: onEdit,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 4),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GlassmorphicButton(
                        showGlow: false,
                        onPressed: onDelete,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: 16),
                            SizedBox(width: 4),
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.truckPrimary,
          ),
          const SizedBox(width: AppDimensions.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.description,
              size: 16,
              color: truck.rcExpiryDate != null ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'RC: ${truck.rcExpiryDate != null ? "Uploaded" : "Pending"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(width: AppDimensions.md),
            Icon(
              Icons.description,
              size: 16,
              color: truck.insuranceExpiryDate != null ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Insurance: ${truck.insuranceExpiryDate != null ? "Uploaded" : "Pending"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'expiring':
        return AppColors.warning;
      case 'expired':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'expiring':
        return Icons.warning;
      case 'expired':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }
}

/// Load Card V2 - Redesigned (MVP 2.0)
/// 
/// New layout with:
/// - Colored route dots (green=from, red=to)
/// - Single-line truck specs
/// - Material + Payment terms row
/// - Embedded SupplierMiniCard
/// - Status badges

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/supplier_mini_card.dart';
import '../../../../shared/widgets/load_status_badge.dart';
import '../../../../shared/widgets/price_display.dart';
import '../../domain/entities/load.dart';

class LoadCardV2 extends StatelessWidget {
  final Load load;
  final VoidCallback onTap;
  final VoidCallback? onSupplierTap;
  final VoidCallback? onCallTap;
  final bool showSupplierCard;
  final String? supplierName;
  final String? supplierPhone;
  final double? supplierRating;
  final int? supplierRatingCount;
  final bool supplierVerified;

  const LoadCardV2({
    super.key,
    required this.load,
    required this.onTap,
    this.onSupplierTap,
    this.onCallTap,
    this.showSupplierCard = true,
    this.supplierName,
    this.supplierPhone,
    this.supplierRating,
    this.supplierRatingCount,
    this.supplierVerified = false,
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
              // Badges row
              _buildBadgesRow(),

              // Route section
              _buildRouteSection(context),

              const SizedBox(height: AppDimensions.sm),

              // Truck specs row
              _buildTruckSpecsRow(context),

              const SizedBox(height: AppDimensions.xs),

              // Material + Payment row
              _buildMaterialPaymentRow(context),

              // Supplier card (if enabled)
              if (showSupplierCard && supplierName != null) ...[
                const SizedBox(height: AppDimensions.sm),
                SupplierMiniCard(
                  supplierId: load.supplierId,
                  supplierName: supplierName!,
                  phoneNumber: supplierPhone,
                  rating: supplierRating,
                  ratingCount: supplierRatingCount,
                  isVerified: supplierVerified,
                  onTap: onSupplierTap,
                  onCallTap: onCallTap ?? _defaultCallTap,
                ),
              ],

              // Loading date
              if (load.loadingDate != null) ...[
                const SizedBox(height: AppDimensions.sm),
                _buildLoadingDate(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    final isLoadingToday = load.loadingDate != null &&
        _isToday(load.loadingDate!);

    return LoadBadgeRow(
      status: load.status,
      isSuperLoad: load.isSuperLoad,
      isLoadingToday: isLoadingToday,
      viewCount: load.viewCount,
      chatCount: load.chatCount,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildRouteSection(BuildContext context) {
    return Column(
      children: [
        // From location
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                load.fromLocationDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // To location
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                load.toLocationDisplay,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTruckSpecsRow(BuildContext context) {
    final specs = <String>[];
    specs.add(load.truckTypeRequired);
    if (load.hasWeight) {
      specs.add('${load.weight!.toStringAsFixed(0)}T');
    }

    return Row(
      children: [
        const Icon(
          Icons.local_shipping_outlined,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            specs.join(' • '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialPaymentRow(BuildContext context) {
    return Row(
      children: [
        // Material
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  load.loadType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Payment badge
        _buildPaymentBadge(context),
      ],
    );
  }

  Widget _buildPaymentBadge(BuildContext context) {
    final priceType = PriceType.fromString(load.priceType);
    
    if (priceType == PriceType.negotiable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Negotiable',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
          ),
        ),
      );
    }

    final hasAdvance = load.advanceRequired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hasAdvance
            ? AppColors.success.withOpacity(0.15)
            : AppColors.info.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 12,
            color: hasAdvance ? AppColors.success : AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            hasAdvance ? 'Advance ${load.advancePercent}%' : 'To Pay',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasAdvance ? AppColors.success : AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDate(BuildContext context) {
    final isToday = _isToday(load.loadingDate!);
    
    return Row(
      children: [
        Icon(
          isToday ? Icons.schedule : Icons.calendar_today_outlined,
          size: 14,
          color: isToday ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          isToday
              ? 'Loading Today'
              : 'Loading: ${Formatters.formatDate(load.loadingDate!)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isToday ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ],
    );
  }

  VoidCallback? get _defaultCallTap {
    if (supplierPhone == null) return null;
    return () async {
      final uri = Uri(scheme: 'tel', path: supplierPhone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    };
  }
}

/// Compact load card for lists (e.g., in supplier profile)
class LoadCardCompact extends StatelessWidget {
  final Load load;
  final VoidCallback onTap;

  const LoadCardCompact({
    super.key,
    required this.load,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.glassSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: AppColors.glassBorder.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Route
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${load.fromCity} → ${load.toCity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${load.loadType} • ${load.weight?.toStringAsFixed(0) ?? "-"}T',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

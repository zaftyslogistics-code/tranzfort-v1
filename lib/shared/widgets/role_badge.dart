import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class RoleBadge extends StatelessWidget {
  final bool isSupplier;
  
  const RoleBadge({
    super.key,
    required this.isSupplier,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSupplier ? AppColors.primary : AppColors.freeModelGreen;
    final label = isSupplier ? 'SUPPLIER' : 'TRUCKER';
    final icon = isSupplier ? Icons.inventory_2_outlined : Icons.local_shipping_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

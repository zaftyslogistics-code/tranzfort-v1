import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final location = GoRouterState.of(context).uri.toString();

    // Determine which navigation to show based on user role
    final isSupplier = user?.isSupplierEnabled ?? false;
    final isTrucker = user?.isTruckerEnabled ?? false;

    if (!isSupplier && !isTrucker) {
      return const SizedBox.shrink(); // No navigation if no role selected
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isSupplier) ...[
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isSelected: location == '/supplier-dashboard',
                  onTap: () => context.go('/supplier-dashboard'),
                ),
                _NavItem(
                  icon: Icons.add_box_outlined,
                  label: 'Post Load',
                  isSelected: location == '/post-load-step1',
                  onTap: () => context.go('/post-load-step1'),
                ),
                _NavItem(
                  icon: Icons.list_alt_outlined,
                  label: 'My Loads',
                  isSelected: location == '/my-loads',
                  onTap: () => context.go('/my-loads'),
                ),
              ] else if (isTrucker) ...[
                _NavItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Find Loads',
                  isSelected: location == '/trucker-feed',
                  onTap: () => context.go('/trucker-feed'),
                ),
                _NavItem(
                  icon: Icons.chat_outlined,
                  label: 'Chat',
                  isSelected: location == '/chat-list',
                  onTap: () => context.go('/chat-list'),
                ),
                _NavItem(
                  icon: Icons.directions_car_outlined,
                  label: 'My Fleet',
                  isSelected: location == '/fleet-management',
                  onTap: () => context.go('/fleet-management'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: location == '/verification',
                  onTap: () => context.go('/verification'),
                ),
              ],
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: location == '/settings',
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

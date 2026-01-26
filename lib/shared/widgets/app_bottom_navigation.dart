import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Bottom Navigation Widget (MVP 2.0)
/// 
/// 4-tab navigation:
/// - Supplier: Post Load | My Loads | Chats | Profile
/// - Trucker: Find Loads | My Trips | Chats | Profile
class AppBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  
  const AppBottomNavigation({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final location = GoRouterState.of(context).uri.toString();

    final isSupplier = user?.isSupplierEnabled ?? false;
    final isTrucker = user?.isTruckerEnabled ?? false;

    if (!isSupplier && !isTrucker) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: isSupplier
                ? _buildSupplierNav(context, location)
                : _buildTruckerNav(context, location),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSupplierNav(BuildContext context, String location) {
    return [
      _NavItem(
        icon: Icons.add_box_outlined,
        activeIcon: Icons.add_box,
        label: 'Post Load',
        isSelected: location.contains('/post-load'),
        onTap: () => context.go('/post-load'),
      ),
      _NavItem(
        icon: Icons.list_alt_outlined,
        activeIcon: Icons.list_alt,
        label: 'My Loads',
        isSelected: location == '/my-loads' || location == '/supplier-dashboard',
        onTap: () => context.go('/my-loads'),
      ),
      _NavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chats',
        isSelected: location.contains('/chat'),
        onTap: () => context.go('/chat-list'),
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        isSelected: location == '/profile' || 
                    location == '/settings' || 
                    location == '/verification',
        onTap: () => context.go('/profile'),
      ),
    ];
  }

  List<Widget> _buildTruckerNav(BuildContext context, String location) {
    return [
      _NavItem(
        icon: Icons.search,
        activeIcon: Icons.search,
        label: 'Find Loads',
        isSelected: location == '/trucker-feed' || location.contains('/filters'),
        onTap: () => context.go('/trucker-feed'),
      ),
      _NavItem(
        icon: Icons.route_outlined,
        activeIcon: Icons.route,
        label: 'My Trips',
        isSelected: location == '/my-trips',
        onTap: () => context.go('/my-trips'),
      ),
      _NavItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chats',
        isSelected: location.contains('/chat'),
        onTap: () => context.go('/chat-list'),
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        isSelected: location == '/profile' || 
                    location == '/settings' || 
                    location == '/verification' ||
                    location == '/fleet-management',
        onTap: () => context.go('/profile'),
      ),
    ];
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingXSmall,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? (activeIcon ?? icon) : icon,
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

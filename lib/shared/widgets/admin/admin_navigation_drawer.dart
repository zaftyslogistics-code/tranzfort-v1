import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Admin navigation drawer with active state indicators
class AdminNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onClose;
  final dynamic admin;

  const AdminNavigationDrawer({
    super.key,
    required this.currentRoute,
    this.onClose,
    this.admin,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.secondaryBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: AppDimensions.xl),
          _buildHeader(),
          const Divider(color: AppColors.glassBorder),
          _buildNavigationItems(context),
          const Divider(color: AppColors.glassBorder),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfort Admin',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    admin?.fullName ?? 'Administrator',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    final navigationItems = [
      _NavigationItem(
        icon: Icons.dashboard,
        label: 'Overview',
        route: '/admin/dashboard',
        isActive: currentRoute == '/admin/dashboard',
      ),
      _NavigationItem(
        icon: Icons.verified_user,
        label: 'KYC Verifications',
        route: '/admin/verifications',
        isActive: currentRoute == '/admin/verifications',
      ),
      _NavigationItem(
        icon: Icons.people,
        label: 'User Management',
        route: '/admin/users',
        isActive: currentRoute == '/admin/users',
      ),
      _NavigationItem(
        icon: Icons.report_problem,
        label: 'Reports & Moderation',
        route: '/admin/reports',
        isActive: currentRoute == '/admin/reports',
      ),
      _NavigationItem(
        icon: Icons.analytics,
        label: 'Analytics',
        route: '/admin/analytics',
        isActive: currentRoute == '/admin/analytics',
      ),
      _NavigationItem(
        icon: Icons.local_shipping,
        label: 'Load Monitoring',
        route: '/admin/loads',
        isActive: currentRoute == '/admin/loads',
      ),
      if (admin?.isSuperAdmin ?? false) ...[
        _NavigationItem(
          icon: Icons.star_border,
          label: 'Super Loads',
          route: '/admin/super-loads',
          isActive: currentRoute.startsWith('/admin/super-loads'),
        ),
        _NavigationItem(
          icon: Icons.add_circle_outline,
          label: 'Create Super Load',
          route: '/admin/super-loads/create-step1',
          isActive: currentRoute == '/admin/super-loads/create-step1',
        ),
      ],
      _NavigationItem(
        icon: Icons.admin_panel_settings,
        label: 'Manage Admins',
        route: '/admin/manage-admins',
        isActive: currentRoute == '/admin/manage-admins',
      ),
      _NavigationItem(
        icon: Icons.settings,
        label: 'System Config',
        route: '/admin/config',
        isActive: currentRoute == '/admin/config',
      ),
    ];

    return Column(
      children: navigationItems.map((item) => _navigationItemWidget(
        item: item,
        onTap: () {
          onClose?.call();
          context.push(item.route);
        },
      )).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          TextButton.icon(
            onPressed: () {
              // Show logout confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to login and clear auth
                        context.go('/admin-login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _navigationItemWidget({
  required _NavigationItem item,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      color: item.isActive
          ? AppColors.primary.withAlpha((0.1 * 255).round())
          : Colors.transparent,
    ),
    child: ListTile(
      leading: Icon(
        item.icon,
        color: item.isActive ? AppColors.primary : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: item.isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: item.isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: item.isActive
          ? Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          : null,
      onTap: onTap,
    ),
  );
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
  });
}

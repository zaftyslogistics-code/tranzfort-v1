import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(authNotifierProvider).admin;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: isMobile ? _buildDrawer(context) : null,
      body: isDesktop || isTablet
          ? Row(
              children: [
                // Desktop/Tablet Sidebar
                Container(
                  width: isDesktop ? 250 : 200,
                  color: AppColors.secondaryBackground,
                  child: _buildSidebarContent(context),
                ),
                // Main Content
                Expanded(child: _buildMainContent(context, admin)),
              ],
            )
          : _buildMainContent(context, admin), // Mobile: full width
    );
  }

  // Build mobile drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.secondaryBackground,
      child: _buildSidebarContent(context),
    );
  }

  // Build sidebar content for both drawer and desktop sidebar
  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.xl),
        _SidebarItem(
          icon: Icons.dashboard,
          label: 'Overview',
          isSelected: true,
          onTap: () => Navigator.of(context).pop(),
        ),
        _SidebarItem(
          icon: Icons.verified_user,
          label: 'KYC Verifications',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/verifications');
          },
        ),
        _SidebarItem(
          icon: Icons.people,
          label: 'User Management',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/users');
          },
        ),
        _SidebarItem(
          icon: Icons.report_problem,
          label: 'Reports & Moderation',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/reports');
          },
        ),
        _SidebarItem(
          icon: Icons.analytics,
          label: 'Analytics',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/analytics');
          },
        ),
        _SidebarItem(
          icon: Icons.local_shipping,
          label: 'Load Monitoring',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/loads');
          },
        ),
        _SidebarItem(
          icon: Icons.admin_panel_settings,
          label: 'Manage Admins',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/manage-admins');
          },
        ),
        _SidebarItem(
          icon: Icons.settings,
          label: 'System Config',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/admin/config');
          },
        ),
      ],
    );
  }

  // Build main content area
  Widget _buildMainContent(BuildContext context, dynamic admin) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? AppDimensions.md : AppDimensions.xl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${admin?.fullName ?? 'Admin'}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 24 : null,
                  ),
            ),
            const SizedBox(height: AppDimensions.xl),
            // Summary Cards - responsive layout
            isMobile
                ? Column(
                    children: [
                      _StatCard(
                        title: 'Pending KYC',
                        value: '12',
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _StatCard(
                        title: 'Active Loads',
                        value: '450',
                        icon: Icons.local_shipping,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _StatCard(
                        title: 'Total Users',
                        value: '1,250',
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _StatCard(
                        title: 'Pending KYC',
                        value: '12',
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: AppDimensions.lg),
                      _StatCard(
                        title: 'Active Loads',
                        value: '450',
                        icon: Icons.local_shipping,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.lg),
                      _StatCard(
                        title: 'Total Users',
                        value: '1,250',
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                    ],
                  ),
            const SizedBox(height: AppDimensions.xl),
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Wrap(
              spacing: AppDimensions.md,
              runSpacing: AppDimensions.md,
              children: [
                _QuickActionCard(
                  title: 'Review KYC',
                  icon: Icons.verified_user,
                  onTap: () => context.push('/admin/verifications'),
                ),
                _QuickActionCard(
                  title: 'Manage Users',
                  icon: Icons.people,
                  onTap: () => context.push('/admin/users'),
                ),
                _QuickActionCard(
                  title: 'Moderation',
                  icon: Icons.report_problem,
                  onTap: () => context.push('/admin/reports'),
                ),
                _QuickActionCard(
                  title: 'Analytics',
                  icon: Icons.analytics,
                  onTap: () => context.push('/admin/analytics'),
                ),
                _QuickActionCard(
                  title: 'Monitor Loads',
                  icon: Icons.local_shipping,
                  onTap: () => context.push('/admin/loads'),
                ),
                _QuickActionCard(
                  title: 'System Config',
                  icon: Icons.settings,
                  onTap: () => context.push('/admin/config'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;

    return isMobile
        ? Card(
            color: AppColors.glassSurfaceStrong,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          )
        : Expanded(
            child: Card(
              color: AppColors.glassSurfaceStrong,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        color: AppColors.glassSurfaceStrong,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primary, size: 32),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppColors.secondaryBackground,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.xl),
                _SidebarItem(
                  icon: Icons.dashboard,
                  label: 'Overview',
                  isSelected: true,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.verified_user,
                  label: 'KYC Verifications',
                  onTap: () => GoRouter.of(context).push('/admin/verifications'),
                ),
                _SidebarItem(
                  icon: Icons.people,
                  label: 'User Management',
                  onTap: () => GoRouter.of(context).push('/admin/users'),
                ),
                _SidebarItem(
                  icon: Icons.local_shipping,
                  label: 'Load Monitoring',
                  onTap: () => GoRouter.of(context).push('/admin/loads'),
                ),
                _SidebarItem(
                  icon: Icons.settings,
                  label: 'System Config',
                  onTap: () => GoRouter.of(context).push('/admin/config'),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${admin?.fullName ?? 'Admin'}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  // Summary Cards
                  Row(
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
                        title: 'Total Revenue',
                        value: '₹24,500',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
    return Expanded(
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
      ),
    );
  }
}

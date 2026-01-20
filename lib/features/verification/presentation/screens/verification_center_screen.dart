import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/free_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'document_upload_screen.dart';

class VerificationCenterScreen extends ConsumerWidget {
  const VerificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    final supplierStatus = user?.supplierVerificationStatus ?? 'unverified';
    final truckerStatus = user?.truckerVerificationStatus ?? 'unverified';

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Center')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBackground,
                    AppColors.secondaryBackground,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(size: 280, color: AppColors.cyanGlowStrong),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(size: 320, color: AppColors.primary),
          ),
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientText(
                      'Get Verified',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Verification unlocks contact features and builds trust.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              GlassmorphicCard(
                backgroundColor: AppColors.glassSurfaceStrong,
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'Document Requirements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _buildRoleRequirements(context, 'supplier'),
                    const SizedBox(height: AppDimensions.md),
                    _buildRoleRequirements(context, 'trucker'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              _VerificationCard(
                title: 'Verify as Supplier',
                subtitle: 'Post unlimited loads - Completely FREE',
                icon: Icons.business_outlined,
                status: supplierStatus,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentUploadScreen(
                        roleType: 'supplier',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.md),
              _VerificationCard(
                title: 'Verify as Trucker',
                subtitle: 'Find unlimited loads - Completely FREE',
                icon: Icons.local_shipping_outlined,
                status: truckerStatus,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentUploadScreen(
                        roleType: 'trucker',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.xl),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  Widget _buildRoleRequirements(BuildContext context, String role) {
    final isSupplier = role == 'supplier';
    final documents = isSupplier 
        ? ['Aadhaar Card', 'PAN Card', 'Transport License']
        : ['Aadhaar Card', 'PAN Card', 'Truck RC'];
    
    final optionalDocs = isSupplier 
        ? ['GST Certificate (Optional)']
        : ['Additional Truck RC (Optional)'];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSupplier ? Icons.business : Icons.local_shipping,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                '${isSupplier ? 'Load Poster' : 'Load Finder'} Requirements',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...documents.map((doc) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  doc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          )),
          ...optionalDocs.map((doc) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  doc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final VoidCallback onTap;

  const _VerificationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final label = _statusLabel(status);

    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      const FreeBadge(text: 'FREE'),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: color.withAlpha((0.35 * 255).round()),
                      ),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not Verified';
    }
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((0.35 * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
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
              _VerificationCard(
                title: 'Verify as Supplier',
                subtitle: 'Post loads and receive inquiries',
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
                subtitle: 'Contact suppliers and find loads',
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
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
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
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
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

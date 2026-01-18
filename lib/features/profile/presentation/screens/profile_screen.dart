import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/formatters.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isVerified =
        (user?.isSupplierVerified ?? false) || (user?.isTruckerVerified ?? false);
    final mobileText = user == null
        ? ''
        : isVerified
            ? '${user.countryCode} ${user.mobileNumber}'
            : '${user.countryCode} ${Formatters.maskMobileNumber(user.mobileNumber)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                      user?.name ?? 'User',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      mobileText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _StatusPill(
                            label: 'Supplier',
                            status: user?.supplierVerificationStatus,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: _StatusPill(
                            label: 'Trucker',
                            status: user?.truckerVerificationStatus,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              GlassmorphicButton(
                variant: GlassmorphicButtonVariant.primary,
                onPressed: () => context.push('/verification'),
                child: const Text('Verification Center'),
              ),
              const SizedBox(height: AppDimensions.sm),
              GlassmorphicButton(
                showGlow: false,
                onPressed: () => context.push('/ratings'),
                child: const Text('Ratings'),
              ),
              const SizedBox(height: AppDimensions.sm),
              GlassmorphicButton(
                showGlow: false,
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String? status;

  const _StatusPill({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final s = status ?? 'unverified';

    Color color;
    String text;

    switch (s) {
      case 'verified':
        color = Colors.green;
        text = 'Verified';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Not Verified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha((0.15 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha((0.35 * 255).round())),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '$label: $text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
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

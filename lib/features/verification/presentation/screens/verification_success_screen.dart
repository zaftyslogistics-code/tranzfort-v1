import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';

class VerificationSuccessScreen extends ConsumerWidget {
  final String roleType;
  final String verificationRequestId;

  const VerificationSuccessScreen({
    super.key,
    required this.roleType,
    required this.verificationRequestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Submitted')),
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            children: [
              GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 72,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    GradientText(
                      'Submitted Successfully',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Your verification request has been submitted for review.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      'Role: $roleType\nRequest: $verificationRequestId',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    GlassmorphicButton(
                      variant: GlassmorphicButtonVariant.primary,
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Home'),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    GlassmorphicButton(
                      showGlow: false,
                      onPressed: () => context.go('/verification'),
                      child: const Text('Back to Verification Center'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

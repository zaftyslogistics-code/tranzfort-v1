import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/cyan_glow_container.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/glow_orb.dart';
import '../providers/auth_provider.dart';
import '../widgets/intent_card.dart';

class IntentSelectionScreen extends ConsumerStatefulWidget {
  const IntentSelectionScreen({super.key});

  @override
  ConsumerState<IntentSelectionScreen> createState() =>
      _IntentSelectionScreenState();
}

class _IntentSelectionScreenState
    extends ConsumerState<IntentSelectionScreen> {
  String? _selectedIntent;

  Future<void> _selectIntent(String intent) async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    Logger.info('🎯 INTENT: User selected intent: $intent');
    setState(() => _selectedIntent = intent);

    final updates = intent == 'supplier'
        ? {'isSupplierEnabled': true}
        : {'isTruckerEnabled': true};

    Logger.info('🎯 INTENT: Updating profile with updates: $updates');

    try {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .updateUserProfile(updates);

      Logger.info('🎯 INTENT: Profile update result: $success');

      // Even if profile update fails, allow navigation
      // The profile update can be retried later
      if (!success) {
        Logger.error('❌ INTENT: Profile update failed, but proceeding with navigation');
        if (!mounted) return;

        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Profile update failed, but you can continue. Settings will be updated later.'),
          ),
        );
      }

      Logger.info('✅ INTENT: Profile updated successfully, navigating to dashboard');

      final updatedAuthState = ref.read(authNotifierProvider);
      Logger.info(
        '🎯 INTENT: Updated user state - Supplier: ${updatedAuthState.user?.isSupplierEnabled}, Trucker: ${updatedAuthState.user?.isTruckerEnabled}',
      );

      if (intent == 'supplier') {
        Logger.info('🚚 INTENT: Navigating to supplier dashboard');
        try {
          // Clear the stack and navigate to dashboard
          router.goNamed('supplier-dashboard');
        } catch (e) {
          Logger.error('❌ INTENT: goNamed error to supplier dashboard: $e');
          // Fallback: try push
          if (mounted) router.push('/supplier-dashboard');
        }
      } else {
        Logger.info('🚚 INTENT: Navigating to trucker feed');
        try {
          // Clear the stack and navigate to trucker feed
          router.goNamed('trucker-feed');
        } catch (e) {
          Logger.error('❌ INTENT: goNamed error to trucker feed: $e');
          // Fallback: try push
          if (mounted) router.push('/trucker-feed');
        }
      }
    } catch (e) {
      Logger.error('❌ INTENT: Error during intent selection: $e');
      if (mounted) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
          ...GlowOrbPresets.getGlowOrbsForScreen('auth'),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                AppDimensions.xl,
                AppDimensions.lg,
                AppDimensions.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CyanGlowContainer(
                          padding: EdgeInsets.all(AppDimensions.md),
                          borderRadius: AppDimensions.radiusFull,
                          backgroundColor: AppColors.glassSurfaceStrong,
                          borderColor: AppColors.glassBorderStrong,
                          child: Icon(
                            Icons.explore_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        GradientText(
                          'Choose your intent',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'What would you like to do?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  IntentCard(
                    icon: Icons.add_box_outlined,
                    title: 'Post Loads',
                    subtitle: 'For load suppliers & transporters',
                    isSelected: _selectedIntent == 'supplier',
                    onTap: authState.isLoading
                        ? () {}
                        : () => _selectIntent('supplier'),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  IntentCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Find Loads',
                    subtitle: 'For truck owners & drivers',
                    isSelected: _selectedIntent == 'trucker',
                    onTap: authState.isLoading
                        ? () {}
                        : () => _selectIntent('trucker'),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  if (authState.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
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

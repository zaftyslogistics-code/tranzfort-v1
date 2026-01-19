import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/cyan_glow_container.dart';
import '../../../../shared/widgets/gradient_text.dart';
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
    setState(() => _selectedIntent = intent);

    final updates = intent == 'supplier'
        ? {'isSupplierEnabled': true}
        : {'isTruckerEnabled': true};

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateUserProfile(updates);

    if (!success) return;
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    
    if (intent == 'supplier') {
      context.go('/supplier-dashboard');
    } else {
      context.go('/trucker-feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
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
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
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

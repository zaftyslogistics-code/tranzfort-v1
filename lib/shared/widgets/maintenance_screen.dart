import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/remote_config_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'glassmorphic_card.dart';
import 'gradient_text.dart';

/// Screen shown when the app is in maintenance mode
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(remoteConfigProvider);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha((0.3 * 255).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.build,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.xl),
                
                // Maintenance Card
                GlassmorphicCard(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Column(
                    children: [
                      const GradientText(
                        'Under Maintenance',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.lg),
                      
                      configAsync.when(
                        data: (config) => Text(
                          config.maintenanceMessage ?? 
                          'Transfort is currently under maintenance. Please try again later.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        loading: () => Text(
                          'Loading maintenance information...',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        error: (_, __) => Text(
                          'Transfort is currently under maintenance. Please try again later.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.xl),
                      
                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Refresh remote config and check maintenance status
                          ref.invalidate(remoteConfigProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.xl,
                            vertical: AppDimensions.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppDimensions.xl),
                
                // Footer
                Text(
                  'We apologize for the inconvenience and appreciate your patience.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary.withAlpha((0.7 * 255).round()),
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

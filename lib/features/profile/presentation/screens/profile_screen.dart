import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_text.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/free_badge.dart';
import '../../../../shared/widgets/glassmorphic_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/formatters.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _updatePreference(String key, bool value) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final currentPreferences = Map<String, dynamic>.from(user.preferences);
    currentPreferences[key] = value;

    await ref.read(authNotifierProvider.notifier).updateUserProfile({
      'preferences': currentPreferences,
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final preferences = user?.preferences ?? {};
    final loadAlertsEnabled =
        preferences['load_alerts_enabled'] as bool? ?? true;
    final chatNotificationsEnabled =
        preferences['chat_notifications_enabled'] as bool? ?? true;

    final isVerified = (user?.isSupplierVerified ?? false) ||
        (user?.isTruckerVerified ?? false);
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
              // User Info Card
              GlassmorphicCard(
                backgroundColor: AppColors.glassSurfaceStrong,
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
                          ?.copyWith(color: AppColors.textPrimary),
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

              // Fleet Overview Card (for truckers)
              if (user?.isTruckerEnabled == true)
                GlassmorphicCard(
                  backgroundColor: AppColors.glassSurfaceStrong,
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  showGlow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GradientText(
                            'My Fleet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const FreeBadge(text: '2 TRUCKS'),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Row(
                        children: [
                          _buildFleetStat(
                            'Active',
                            '2',
                            Icons.check_circle,
                            AppColors.success,
                          ),
                          const SizedBox(width: AppDimensions.lg),
                          _buildFleetStat(
                            'Expiring',
                            '0',
                            Icons.warning,
                            AppColors.warning,
                          ),
                          const SizedBox(width: AppDimensions.lg),
                          _buildFleetStat(
                            'Total',
                            '2',
                            Icons.local_shipping,
                            AppColors.truckPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),
                      GlassmorphicButton(
                        variant: GlassmorphicButtonVariant.ghost,
                        onPressed: () => context.push('/fleet-management'),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car, size: 16),
                            SizedBox(width: 4),
                            Text('Manage Fleet'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppDimensions.lg),

              // Notification Preferences Card
              GlassmorphicCard(
                backgroundColor: AppColors.glassSurfaceStrong,
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    SwitchListTile(
                      title: Text(
                        'Load Alerts',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Get notified about matching loads',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      value: loadAlertsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (value) =>
                          _updatePreference('load_alerts_enabled', value),
                    ),
                    SwitchListTile(
                      title: Text(
                        'Chat Notifications',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Get notified about new messages',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      value: chatNotificationsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (value) => _updatePreference(
                          'chat_notifications_enabled', value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassmorphicButton(
                  variant: GlassmorphicButtonVariant.primary,
                  onPressed: () => context.push('/verification'),
                  child: const Text('Verification Center'),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassmorphicButton(
                  showGlow: false,
                  onPressed: () => context.push('/ratings'),
                  child: const Text('Ratings'),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassmorphicButton(
                  showGlow: false,
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  Widget _buildFleetStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
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
        color = AppColors.success;
        text = 'Verified';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'Pending';
        break;
      case 'rejected':
        color = AppColors.danger;
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

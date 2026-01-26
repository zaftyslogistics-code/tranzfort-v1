/// Supplier Profile Screen (MVP 2.0)
/// 
/// Shows supplier details, ratings, operating routes, products, and active loads.
/// Accessible by tapping supplier card in load detail or load card.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../loads/presentation/widgets/load_card_v2.dart';
import '../../../loads/domain/entities/load.dart';
import '../providers/supplier_profile_provider.dart';

class SupplierProfileScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierProfileScreen({
    super.key,
    required this.supplierId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(supplierProfileProvider(supplierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBackground, AppColors.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyStatePresets.error(
            message: error.toString(),
            onRetry: () => ref.refresh(supplierProfileProvider(supplierId)),
          ),
          data: (profile) => _buildContent(context, ref, profile),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SupplierProfile profile,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        // Header card
        _buildHeaderCard(context, profile),

        const SizedBox(height: AppDimensions.paddingMedium),

        // Action buttons
        _buildActionButtons(context, profile),

        const SizedBox(height: AppDimensions.paddingLarge),

        // Rating section
        if (profile.rating != null) ...[
          _buildRatingSection(context, profile),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Operating routes
        if (profile.operatingRoutes.isNotEmpty) ...[
          _buildOperatingRoutes(context, profile),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Products handled
        if (profile.productsHandled.isNotEmpty) ...[
          _buildProductsHandled(context, profile),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Active loads
        _buildActiveLoads(context, profile),

        const SizedBox(height: AppDimensions.paddingXLarge),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, SupplierProfile profile) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    _getInitials(profile.name),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (profile.isVerified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingMedium),

            // Name
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            // Location
            if (profile.location != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.location!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // Verified badge
            if (profile.isVerified) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SupplierProfile profile) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navigate to chat
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: profile.phone != null
                ? () => _launchPhone(profile.phone!)
                : null,
            icon: const Icon(Icons.phone),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, SupplierProfile profile) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating header
            Row(
              children: [
                Text(
                  profile.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < profile.rating!.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 20,
                          color: AppColors.warning,
                        );
                      }),
                    ),
                    Text(
                      '${profile.ratingCount ?? 0} ratings',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Rating breakdown
            if (profile.paymentScore != null || profile.serviceScore != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  if (profile.paymentScore != null)
                    _buildScoreBadge(
                      'Payment',
                      profile.paymentScore!,
                      Icons.payments_outlined,
                    ),
                  if (profile.paymentScore != null && profile.serviceScore != null)
                    const SizedBox(width: AppDimensions.paddingSmall),
                  if (profile.serviceScore != null)
                    _buildScoreBadge(
                      'Service',
                      profile.serviceScore!,
                      Icons.handshake_outlined,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(String label, int percentage, IconData icon) {
    final isGood = percentage >= 80;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: (isGood ? AppColors.success : AppColors.warning).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isGood ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$percentage% 👍',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isGood ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingRoutes(BuildContext context, SupplierProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Operating Routes', Icons.route),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: profile.operatingRoutes.take(6).map((route) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderLight.withOpacity(0.2),
                ),
              ),
              child: Text(
                route,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        ),
        if (profile.operatingRoutes.length > 6) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            '+${profile.operatingRoutes.length - 6} more routes',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductsHandled(BuildContext context, SupplierProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Products Handled', Icons.inventory_2_outlined),
        const SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: profile.productsHandled.take(8).map((product) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                product,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            );
          }).toList(),
        ),
        if (profile.productsHandled.length > 8) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            '+${profile.productsHandled.length - 8} more',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveLoads(BuildContext context, SupplierProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Active Loads (${profile.activeLoads.length})',
          Icons.local_shipping_outlined,
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        if (profile.activeLoads.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Center(
              child: Text(
                'No active loads',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...profile.activeLoads.map((load) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: LoadCardCompact(
                  load: load,
                  onTap: () {
                    context.push('/load-detail-trucker', extra: load.id);
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

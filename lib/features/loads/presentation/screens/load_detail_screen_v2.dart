import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_button.dart';
import '../../../../shared/widgets/flat_card.dart';

/// Load Detail Screen v0.02
/// Shows load details with flat design
/// For Super Loads: Shows "Chat with us" CTA if trucker not approved
class LoadDetailScreenV2 extends ConsumerWidget {
  final String loadId;
  final bool isTruckerView;

  const LoadDetailScreenV2({
    super.key,
    required this.loadId,
    this.isTruckerView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock data - replace with actual provider
    final load = {
      'id': loadId,
      'fromCity': 'Mumbai',
      'fromState': 'Maharashtra',
      'toCity': 'Delhi',
      'toState': 'Delhi',
      'materialType': 'Steel',
      'truckType': '32 Ft Trailer',
      'weight': '20 tons',
      'price': '₹45,000',
      'date': 'Today, 3:00 PM',
      'distance': '1,400 km',
      'supplierName': 'ABC Transport Ltd',
      'supplierPhone': '+91 98765 43210',
      'isVerified': true,
      'isSuperLoad': true,
      'description': 'Urgent delivery required. Load ready for pickup.',
    };

    // Mock user approval status
    final isSuperLoadsApproved = false; // Replace with actual check

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Load Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Toggle bookmark
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share load
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Super Load Badge
                  if (load['isSuperLoad'] == true) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SUPER LOAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Route
                  Text(
                    '${load['fromCity']} → ${load['toCity']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${load['fromState']} → ${load['toState']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Load Info Card
                  FlatCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Material',
                          value: load['materialType'] as String,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Truck Type',
                          value: load['truckType'] as String,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.scale_outlined,
                          label: 'Weight',
                          value: load['weight'] as String,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.route_outlined,
                          label: 'Distance',
                          value: load['distance'] as String,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Pickup Date',
                          value: load['date'] as String,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Card
                  FlatCard(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    borderColor: AppColors.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offered Price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          load['price'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (load['description'] != null) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FlatCard(
                      child: Text(
                        load['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Supplier Info
                  Text(
                    'Posted By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlatCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    load['supplierName'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  if (load['isVerified'] == true) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                load['supplierPhone'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTAs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: _buildCTAs(context, load, isSuperLoadsApproved),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAs(BuildContext context, Map<String, dynamic> load, bool isApproved) {
    final isSuperLoad = load['isSuperLoad'] == true;

    // Super Load + Not Approved = Show "Chat with us" CTA
    if (isTruckerView && isSuperLoad && !isApproved) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              border: Border.all(color: AppColors.info),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get verified to access Super Loads',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Chat with us',
            icon: Icons.chat_bubble_outline,
            onPressed: () {
              // TODO: Open support chat for Super Loads approval
              context.push('/support-chat');
            },
          ),
        ],
      );
    }

    // Regular load or approved trucker = Show normal CTAs
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Call Now',
            icon: Icons.phone,
            onPressed: () {
              // TODO: Make call
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            text: 'Send Offer',
            icon: Icons.send,
            onPressed: () {
              // TODO: Send offer
            },
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// SupplierMiniCard Widget
/// 
/// Compact supplier card embedded in load cards.
/// Shows verified badge, name, rating, and call button.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class SupplierMiniCard extends StatelessWidget {
  final String supplierId;
  final String supplierName;
  final String? phoneNumber;
  final double? rating;
  final int? ratingCount;
  final bool isVerified;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;

  const SupplierMiniCard({
    super.key,
    required this.supplierId,
    required this.supplierName,
    this.phoneNumber,
    this.rating,
    this.ratingCount,
    this.isVerified = false,
    this.onTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          border: Border.all(
            color: AppColors.borderLight.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Verified badge + Avatar placeholder
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    _getInitials(supplierName),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: AppDimensions.paddingSmall),

            // Name and rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (isVerified) ...[
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          supplierName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (ratingCount != null) ...[
                          Text(
                            ' ($ratingCount)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Call button
            if (phoneNumber != null || onCallTap != null)
              _CallButton(
                onTap: onCallTap ?? () => _launchPhone(phoneNumber!),
              ),
          ],
        ),
      ),
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

class _CallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.success,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.phone,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: 4),
              Text(
                'Call',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Larger supplier card for load detail screen
class SupplierCard extends StatelessWidget {
  final String supplierId;
  final String supplierName;
  final String? fullName;
  final String? location;
  final String? phoneNumber;
  final double? rating;
  final int? ratingCount;
  final bool isVerified;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;

  const SupplierCard({
    super.key,
    required this.supplierId,
    required this.supplierName,
    this.fullName,
    this.location,
    this.phoneNumber,
    this.rating,
    this.ratingCount,
    this.isVerified = false,
    this.onTap,
    this.onCallTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: AppColors.borderLight.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        _getInitials(supplierName),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (isVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: AppDimensions.paddingMedium),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isVerified) ...[
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              supplierName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (fullName != null && fullName != supplierName) ...[
                        const SizedBox(height: 2),
                        Text(
                          fullName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (location != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < rating!.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: AppColors.warning,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (ratingCount != null) ...[
                              Text(
                                ' ($ratingCount ratings)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons
            if (onCallTap != null || onChatTap != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  if (onChatTap != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onChatTap,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Chat'),
                      ),
                    ),
                  if (onCallTap != null && onChatTap != null)
                    const SizedBox(width: AppDimensions.paddingSmall),
                  if (onCallTap != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onCallTap,
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // Tap for profile hint
            if (onTap != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to view full profile',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
}

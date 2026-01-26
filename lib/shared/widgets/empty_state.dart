/// EmptyState Widget
/// 
/// Reusable widget for displaying empty states with icon, message, and CTA.
/// Used across screens when no data is available.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? ctaText;
  final VoidCallback? onCtaTap;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ctaText,
    this.onCtaTap,
    this.iconSize = 64,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.primary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // CTA Button
            if (ctaText != null && onCtaTap != null) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton(
                onPressed: onCtaTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                ),
                child: Text(ctaText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common screens
class EmptyStatePresets {
  EmptyStatePresets._();

  /// No loads posted (Supplier)
  static EmptyState noLoadsPosted({VoidCallback? onPostLoad}) {
    return EmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'No loads posted yet',
      subtitle: 'Post your first load to start receiving inquiries from truckers',
      ctaText: 'POST YOUR FIRST LOAD',
      onCtaTap: onPostLoad,
    );
  }

  /// No trips (Trucker)
  static EmptyState noTrips({VoidCallback? onFindLoads}) {
    return EmptyState(
      icon: Icons.route_outlined,
      title: 'No trips yet',
      subtitle: 'Find loads to get started and track your trips here',
      ctaText: 'FIND LOADS',
      onCtaTap: onFindLoads,
    );
  }

  /// No chats
  static EmptyState noChats({VoidCallback? onFindLoads}) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'No conversations yet',
      subtitle: 'Start chatting with suppliers or truckers to negotiate deals',
      ctaText: 'FIND LOADS',
      onCtaTap: onFindLoads,
    );
  }

  /// No fleet (Trucker)
  static EmptyState noFleet({VoidCallback? onAddTruck}) {
    return EmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'No trucks added yet',
      subtitle: 'Add your trucks to get personalized load recommendations',
      ctaText: 'ADD TRUCK',
      onCtaTap: onAddTruck,
    );
  }

  /// No search results
  static EmptyState noSearchResults({VoidCallback? onClearFilters}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No loads found',
      subtitle: 'Try adjusting your filters or search in a different route',
      ctaText: 'CLEAR FILTERS',
      onCtaTap: onClearFilters,
      iconColor: AppColors.textSecondary,
    );
  }

  /// No call history
  static EmptyState noCallHistory({VoidCallback? onFindLoads}) {
    return EmptyState(
      icon: Icons.phone_outlined,
      title: 'No calls made yet',
      subtitle: 'Call suppliers to discuss loads and see your history here',
      ctaText: 'FIND LOADS',
      onCtaTap: onFindLoads,
    );
  }

  /// No notifications
  static EmptyState noNotifications() {
    return const EmptyState(
      icon: Icons.notifications_none,
      title: 'No notifications',
      subtitle: 'You\'re all caught up! Check back later for updates',
    );
  }

  /// Error state
  static EmptyState error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      subtitle: message ?? 'Please try again later',
      ctaText: 'RETRY',
      onCtaTap: onRetry,
      iconColor: AppColors.error,
    );
  }

  /// No internet
  static EmptyState noInternet({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'No internet connection',
      subtitle: 'Check your connection and try again',
      ctaText: 'RETRY',
      onCtaTap: onRetry,
      iconColor: AppColors.warning,
    );
  }
}

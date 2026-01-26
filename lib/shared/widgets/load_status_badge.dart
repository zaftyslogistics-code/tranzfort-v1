/// LoadStatusBadge Widget
/// 
/// Badge widget for displaying load status (Active, High Demand, Booked, etc.)
/// and special badges like Super Load.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Load status enum
enum LoadStatus {
  active('active'),
  highDemand('high_demand'),
  booked('booked'),
  expired('expired'),
  completed('completed');

  final String value;
  const LoadStatus(this.value);

  static LoadStatus fromString(String? value) {
    return LoadStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LoadStatus.active,
    );
  }
}

/// Badge configuration for each status
class _BadgeConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const _BadgeConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });
}

class LoadStatusBadge extends StatelessWidget {
  final LoadStatus status;
  final bool compact;

  const LoadStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  /// Create from status string
  factory LoadStatusBadge.fromString(String statusString, {bool compact = false}) {
    return LoadStatusBadge(
      status: LoadStatus.fromString(statusString),
      compact: compact,
    );
  }

  /// Create high demand badge based on view and chat counts
  factory LoadStatusBadge.highDemandIf({
    required int viewCount,
    required int chatCount,
    required String currentStatus,
    bool compact = false,
  }) {
    // High demand if: views > 50 OR chats > 5, AND status is active
    final isHighDemand = currentStatus == 'active' &&
        (viewCount > 50 || chatCount > 5);

    return LoadStatusBadge(
      status: isHighDemand ? LoadStatus.highDemand : LoadStatus.fromString(currentStatus),
      compact: compact,
    );
  }

  _BadgeConfig get _config {
    switch (status) {
      case LoadStatus.active:
        return _BadgeConfig(
          label: 'Active',
          backgroundColor: AppColors.success.withOpacity(0.15),
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case LoadStatus.highDemand:
        return _BadgeConfig(
          label: 'High Demand',
          backgroundColor: AppColors.warning.withOpacity(0.15),
          textColor: AppColors.warning,
          icon: Icons.local_fire_department,
        );
      case LoadStatus.booked:
        return _BadgeConfig(
          label: 'Booked',
          backgroundColor: AppColors.info.withOpacity(0.15),
          textColor: AppColors.info,
          icon: Icons.handshake_outlined,
        );
      case LoadStatus.expired:
        return _BadgeConfig(
          label: 'Expired',
          backgroundColor: AppColors.error.withOpacity(0.15),
          textColor: AppColors.error,
          icon: Icons.timer_off_outlined,
        );
      case LoadStatus.completed:
        return _BadgeConfig(
          label: 'Completed',
          backgroundColor: AppColors.textSecondary.withOpacity(0.15),
          textColor: AppColors.textSecondary,
          icon: Icons.done_all,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.icon != null && !compact) ...[
            Icon(
              config.icon,
              size: 14,
              color: config.textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            config.label,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Super Load badge (premium/admin-posted loads)
class SuperLoadBadge extends StatelessWidget {
  final bool compact;

  const SuperLoadBadge({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFFA500), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            const Icon(
              Icons.star,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'SUPER LOAD',
            style: TextStyle(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading today badge
class LoadingTodayBadge extends StatelessWidget {
  final bool compact;

  const LoadingTodayBadge({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(
              Icons.schedule,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'Loading Today',
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Composite badge row for load cards
class LoadBadgeRow extends StatelessWidget {
  final String status;
  final bool isSuperLoad;
  final bool isLoadingToday;
  final int viewCount;
  final int chatCount;

  const LoadBadgeRow({
    super.key,
    required this.status,
    this.isSuperLoad = false,
    this.isLoadingToday = false,
    this.viewCount = 0,
    this.chatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Super load badge (highest priority)
    if (isSuperLoad) {
      badges.add(const SuperLoadBadge(compact: true));
    }

    // Loading today badge
    if (isLoadingToday) {
      badges.add(const LoadingTodayBadge(compact: true));
    }

    // Status badge (show High Demand if applicable)
    final loadStatus = LoadStatusBadge.highDemandIf(
      viewCount: viewCount,
      chatCount: chatCount,
      currentStatus: status,
      compact: true,
    );

    // Only show status badge if not active (active is default)
    if (loadStatus.status != LoadStatus.active) {
      badges.add(loadStatus);
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppDimensions.paddingXSmall,
      runSpacing: AppDimensions.paddingXSmall,
      children: badges,
    );
  }
}

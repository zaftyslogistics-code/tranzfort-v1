import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flat_card.dart';

/// History Timeline Screen v0.02
/// Shows non-deletable business records for suppliers and truckers
class HistoryTimelineScreen extends ConsumerWidget {
  final String userId;
  final String userType; // 'supplier' or 'trucker'

  const HistoryTimelineScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock history data
    final historyItems = userType == 'supplier'
        ? _getSupplierHistory()
        : _getTruckerHistory();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Business History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: historyItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                final isFirst = index == 0;
                final isLast = index == historyItems.length - 1;

                return _TimelineItem(
                  item: item,
                  isFirst: isFirst,
                  isLast: isLast,
                  isDark: isDark,
                );
              },
            ),
    );
  }

  List<Map<String, dynamic>> _getSupplierHistory() {
    return [
      {
        'type': 'load_posted',
        'title': 'Load Posted',
        'description': 'Mumbai → Delhi, Steel, 20 tons',
        'date': '2 days ago',
        'status': 'completed',
      },
      {
        'type': 'load_completed',
        'title': 'Load Completed',
        'description': 'Pune → Bangalore, Cement, 15 tons',
        'date': '1 week ago',
        'status': 'completed',
      },
      {
        'type': 'verification',
        'title': 'Account Verified',
        'description': 'Documents approved by admin',
        'date': '2 weeks ago',
        'status': 'completed',
      },
    ];
  }

  List<Map<String, dynamic>> _getTruckerHistory() {
    return [
      {
        'type': 'trip_completed',
        'title': 'Trip Completed',
        'description': 'Mumbai → Delhi, 20 tons',
        'date': '1 day ago',
        'status': 'completed',
      },
      {
        'type': 'super_trucker',
        'title': 'Super Trucker Approved',
        'description': 'Access to premium loads granted',
        'date': '1 month ago',
        'status': 'completed',
      },
      {
        'type': 'verification',
        'title': 'Account Verified',
        'description': 'Documents approved by admin',
        'date': '3 months ago',
        'status': 'completed',
      },
    ];
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isFirst;
  final bool isLast;
  final bool isDark;

  const _TimelineItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getIconColor(item['type'] as String),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getIcon(item['type'] as String),
                size: 16,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: FlatCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (item['status'] as String).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'load_posted':
        return Icons.add_circle;
      case 'load_completed':
      case 'trip_completed':
        return Icons.check_circle;
      case 'super_trucker':
        return Icons.star;
      case 'verification':
        return Icons.verified;
      default:
        return Icons.circle;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'load_posted':
        return AppColors.info;
      case 'load_completed':
      case 'trip_completed':
        return AppColors.success;
      case 'super_trucker':
        return AppColors.primary;
      case 'verification':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final markAllAsRead = ref.watch(markAllNotificationsAsReadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await markAllAsRead();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark all read'),
          ),
        ],
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
          ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              notificationsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return GlassmorphicCard(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'No notifications yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: items
                        .map(
                          (n) => _buildNotificationItem(
                            context,
                            icon: Icons.notifications,
                            title: n.title,
                            message: n.message,
                            time: n.createdAt,
                            isRead: n.isRead,
                          ),
                        )
                        .toList(growable: false),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppDimensions.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => GlassmorphicCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Text(
                    e.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required DateTime time,
    required bool isRead,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: isRead
                  ? AppColors.textSecondary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(
              icon,
              color: isRead ? AppColors.textSecondary : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  timeago.format(time),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

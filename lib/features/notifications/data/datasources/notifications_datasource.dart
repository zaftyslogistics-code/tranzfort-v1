import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../../../core/services/offline_cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/retry.dart';

class NotificationsDataSource {
  final SupabaseClient _supabase;

  NotificationsDataSource(this._supabase);

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await retry(
        () => _supabase
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(50),
      );

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList(growable: false);

      await OfflineCacheService().cacheList(
        OfflineCacheService.notificationsKey,
        notifications.map((n) => n.toJson()).toList(growable: false),
      );

      return notifications;
    } catch (e) {
      Logger.error('Failed to get notifications: $e');

      final cached = OfflineCacheService().getCachedList(
        OfflineCacheService.notificationsKey,
      );

      if (cached != null) {
        return cached
            .map((json) => NotificationModel.fromJson(json))
            .toList(growable: false);
      }

      rethrow;
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response =
          await _supabase.rpc('get_unread_notification_count', params: {
        'p_user_id': userId,
      });

      if (response is int) return response;

      if (response is num) return response.toInt();

      return int.tryParse(response.toString()) ?? 0;
    } catch (e) {
      Logger.error('Failed to get unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      Logger.error('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      Logger.error('Failed to mark all as read: $e');
      rethrow;
    }
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) =>
            rows.map((row) => NotificationModel.fromJson(row)).toList());
  }
}

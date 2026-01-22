import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/notifications_datasource.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationsDataSourceProvider =
    Provider<NotificationsDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return NotificationsDataSource(supabase);
});

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return const Stream.empty();

  final ds = ref.watch(notificationsDataSourceProvider);
  return ds.watchNotifications(user.id);
});

final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return 0;

  final ds = ref.watch(notificationsDataSourceProvider);
  return ds.getUnreadCount(user.id);
});

final markAllNotificationsAsReadProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final ds = ref.read(notificationsDataSourceProvider);
    await ds.markAllAsRead(user.id);
  };
});

final markNotificationAsReadProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (notificationId) async {
    final ds = ref.read(notificationsDataSourceProvider);
    await ds.markAsRead(notificationId);
  };
});

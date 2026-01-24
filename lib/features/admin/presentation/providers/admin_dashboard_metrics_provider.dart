import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardMetrics {
  final int pendingKyc;
  final int activeLoads;
  final int totalUsers;

  const AdminDashboardMetrics({
    required this.pendingKyc,
    required this.activeLoads,
    required this.totalUsers,
  });
}

final adminDashboardMetricsProvider =
    FutureProvider<AdminDashboardMetrics>((ref) async {
  final client = Supabase.instance.client;

  // NOTE: This codebase's PostgREST client version doesn't expose count/head
  // options in `select()` (and doesn't support `.in_()`), so we compute counts
  // by selecting lightweight `id` lists and taking `length`.
  final pendingRows = await client
      .from('verification_requests')
      .select('id')
      .or('status.eq.pending,status.eq.needs_more_info') as List;

  final activeLoadRows = await client
      .from('loads')
      .select('id')
      .eq('status', 'active')
      .gt('expires_at', DateTime.now().toIso8601String()) as List;

  final userRows = await client.from('users').select('id') as List;

  return AdminDashboardMetrics(
    pendingKyc: pendingRows.length,
    activeLoads: activeLoadRows.length,
    totalUsers: userRows.length,
  );
});

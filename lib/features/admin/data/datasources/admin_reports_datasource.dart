import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_report_model.dart';

abstract class AdminReportsDataSource {
  Future<List<UserReportModel>> getReports({String? status});
  Future<void> updateReportStatus(String reportId, String status,
      {String? adminNotes});
}

class SupabaseAdminReportsDataSource implements AdminReportsDataSource {
  final SupabaseClient _client;

  SupabaseAdminReportsDataSource(this._client);

  @override
  Future<List<UserReportModel>> getReports({String? status}) async {
    var query = _client.from('user_reports').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => UserReportModel.fromJson(e)).toList();
  }

  @override
  Future<void> updateReportStatus(String reportId, String status,
      {String? adminNotes}) async {
    final updates = {
      'status': status,
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (status == 'resolved' || status == 'dismissed') ...{
        'resolved_by': _client.auth.currentUser?.id,
        'resolved_at': DateTime.now().toIso8601String(),
      }
    };

    await _client.from('user_reports').update(updates).eq('id', reportId);
  }
}

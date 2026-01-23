import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/admin_model.dart';

abstract class AdminDataSource {
  Future<List<AdminModel>> getAllAdmins();
  Future<AdminModel> createAdmin({
    required String userId,
    required String role,
    String? fullName,
  });
  Future<AdminModel> updateAdmin({
    required String adminId,
    required Map<String, dynamic> updates,
  });
  Future<void> deleteAdmin(String adminId);
  Future<void> logAuditAction({
    required String adminId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  });
}

class SupabaseAdminDataSource implements AdminDataSource {
  final SupabaseClient _client;

  SupabaseAdminDataSource(this._client);

  @override
  Future<List<AdminModel>> getAllAdmins() async {
    final response = await _client
        .from('admin_profiles')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((json) => AdminModel.fromJson(json)).toList();
  }

  @override
  Future<AdminModel> createAdmin({
    required String userId,
    required String role,
    String? fullName,
  }) async {
    final response = await _client
        .from('admin_profiles')
        .insert({
          'id': userId,
          'role': role,
          'full_name': fullName,
        })
        .select()
        .single();

    return AdminModel.fromJson(response);
  }

  @override
  Future<AdminModel> updateAdmin({
    required String adminId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await _client
        .from('admin_profiles')
        .update(updates)
        .eq('id', adminId)
        .select()
        .single();

    return AdminModel.fromJson(response);
  }

  @override
  Future<void> deleteAdmin(String adminId) async {
    await _client.from('admin_profiles').delete().eq('id', adminId);
  }

  @override
  Future<void> logAuditAction({
    required String adminId,
    required String action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    await _client.from('audit_logs').insert({
      'admin_id': adminId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'old_data': oldData,
      'new_data': newData,
    });
  }
}

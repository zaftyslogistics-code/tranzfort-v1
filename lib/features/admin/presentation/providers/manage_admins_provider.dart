import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/admin_model.dart';
import '../../data/datasources/admin_datasource.dart';

class ManageAdminsState {
  final List<AdminModel> admins;
  final bool isLoading;
  final String? error;

  ManageAdminsState({
    this.admins = const [],
    this.isLoading = false,
    this.error,
  });

  ManageAdminsState copyWith({
    List<AdminModel>? admins,
    bool? isLoading,
    String? error,
  }) {
    return ManageAdminsState(
      admins: admins ?? this.admins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ManageAdminsNotifier extends StateNotifier<ManageAdminsState> {
  final AdminDataSource _dataSource;
  final String _currentAdminId;

  ManageAdminsNotifier(this._dataSource, this._currentAdminId)
      : super(ManageAdminsState());

  Future<void> fetchAdmins() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final admins = await _dataSource.getAllAdmins();
      state = state.copyWith(isLoading: false, admins: admins);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createAdmin({
    required String userId,
    required String role,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newAdmin = await _dataSource.createAdmin(
        userId: userId,
        role: role,
        fullName: fullName,
      );

      await _dataSource.logAuditAction(
        adminId: _currentAdminId,
        action: 'admin_created',
        entityType: 'admin_profile',
        entityId: newAdmin.id,
        newData: {'role': role, 'full_name': fullName},
      );

      final updatedAdmins = [...state.admins, newAdmin];
      state = state.copyWith(isLoading: false, admins: updatedAdmins);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAdminRole({
    required String adminId,
    required String newRole,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final oldAdmin = state.admins.firstWhere((a) => a.id == adminId);
      final updatedAdmin = await _dataSource.updateAdmin(
        adminId: adminId,
        updates: {'role': newRole},
      );

      await _dataSource.logAuditAction(
        adminId: _currentAdminId,
        action: 'admin_role_updated',
        entityType: 'admin_profile',
        entityId: adminId,
        oldData: {'role': oldAdmin.role},
        newData: {'role': newRole},
      );

      final updatedAdmins =
          state.admins.map((a) => a.id == adminId ? updatedAdmin : a).toList();
      state = state.copyWith(isLoading: false, admins: updatedAdmins);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final oldAdmin = state.admins.firstWhere((a) => a.id == adminId);
      await _dataSource.deleteAdmin(adminId);

      await _dataSource.logAuditAction(
        adminId: _currentAdminId,
        action: 'admin_deleted',
        entityType: 'admin_profile',
        entityId: adminId,
        oldData: {'role': oldAdmin.role, 'full_name': oldAdmin.fullName},
      );

      final updatedAdmins = state.admins.where((a) => a.id != adminId).toList();
      state = state.copyWith(isLoading: false, admins: updatedAdmins);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final manageAdminsNotifierProvider = StateNotifierProvider.family<
    ManageAdminsNotifier, ManageAdminsState, String>(
  (ref, currentAdminId) {
    final client = Supabase.instance.client;
    final dataSource = SupabaseAdminDataSource(client);
    return ManageAdminsNotifier(dataSource, currentAdminId);
  },
);

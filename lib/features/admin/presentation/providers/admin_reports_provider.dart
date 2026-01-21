import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/admin_reports_datasource.dart';
import '../../data/models/user_report_model.dart';

final adminReportsDataSourceProvider = Provider<AdminReportsDataSource>((ref) {
  return SupabaseAdminReportsDataSource(Supabase.instance.client);
});

class AdminReportsState {
  final List<UserReportModel> reports;
  final bool isLoading;
  final String? error;
  final String currentFilter;

  AdminReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.currentFilter = 'all',
  });

  AdminReportsState copyWith({
    List<UserReportModel>? reports,
    bool? isLoading,
    String? error,
    String? currentFilter,
  }) {
    return AdminReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class AdminReportsNotifier extends StateNotifier<AdminReportsState> {
  final AdminReportsDataSource _dataSource;

  AdminReportsNotifier(this._dataSource) : super(AdminReportsState());

  Future<void> fetchReports({String? status}) async {
    state = state.copyWith(isLoading: true, error: null, currentFilter: status ?? 'all');
    try {
      final reports = await _dataSource.getReports(status: status == 'all' ? null : status);
      state = state.copyWith(isLoading: false, reports: reports);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateReportStatus(String reportId, String newStatus, {String? adminNotes}) async {
    try {
      await _dataSource.updateReportStatus(reportId, newStatus, adminNotes: adminNotes);
      // Refresh list
      await fetchReports(status: state.currentFilter == 'all' ? null : state.currentFilter);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adminReportsProvider =
    StateNotifierProvider<AdminReportsNotifier, AdminReportsState>((ref) {
  final dataSource = ref.watch(adminReportsDataSourceProvider);
  return AdminReportsNotifier(dataSource);
});

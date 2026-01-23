import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../verification/data/models/verification_request_model.dart';
import '../../../verification/presentation/providers/verification_provider.dart';
import '../../data/datasources/admin_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminVerificationState {
  final List<VerificationRequestModel> pendingRequests;
  final bool isLoading;
  final String? error;

  AdminVerificationState({
    this.pendingRequests = const [],
    this.isLoading = false,
    this.error,
  });

  AdminVerificationState copyWith({
    List<VerificationRequestModel>? pendingRequests,
    bool? isLoading,
    String? error,
  }) {
    return AdminVerificationState(
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminVerificationNotifier extends StateNotifier<AdminVerificationState> {
  final Ref _ref;

  AdminVerificationNotifier(this._ref) : super(AdminVerificationState());

  Future<void> fetchPendingRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(getPendingVerificationRequestsUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (requests) =>
          state = state.copyWith(isLoading: false, pendingRequests: requests),
    );
  }

  Future<bool> updateStatus(String requestId, String status,
      {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(updateVerificationStatusUseCaseProvider);
    final result = await useCase(
      requestId: requestId,
      status: status,
      rejectionReason: reason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedRequest) async {
        final updatedList =
            state.pendingRequests.where((req) => req.id != requestId).toList();
        state = state.copyWith(isLoading: false, pendingRequests: updatedList);

        final adminId = _ref.read(authNotifierProvider).user?.id;
        if (adminId != null) {
          try {
            final dataSource =
                SupabaseAdminDataSource(Supabase.instance.client);

            String action;
            switch (status) {
              case 'approved':
                action = 'verification_approved';
                break;
              case 'rejected':
                action = 'verification_rejected';
                break;
              case 'needs_more_info':
                action = 'verification_needs_more_info';
                break;
              default:
                action = 'verification_status_updated';
            }

            await dataSource.logAuditAction(
              adminId: adminId,
              action: action,
              entityType: 'verification_request',
              entityId: requestId,
              oldData: {'status': 'pending'},
              newData: {
                'status': status,
                if (reason != null) 'rejection_reason': reason,
              },
            );
          } catch (e) {
            // Log error but don't fail the operation
          }
        }

        return true;
      },
    );
  }
}

final adminVerificationNotifierProvider =
    StateNotifierProvider<AdminVerificationNotifier, AdminVerificationState>(
        (ref) {
  return AdminVerificationNotifier(ref);
});

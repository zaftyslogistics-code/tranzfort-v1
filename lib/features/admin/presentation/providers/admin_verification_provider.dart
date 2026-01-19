import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../verification/data/models/verification_request_model.dart';
import '../../../verification/presentation/providers/verification_provider.dart';

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
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (requests) => state = state.copyWith(isLoading: false, pendingRequests: requests),
    );
  }

  Future<bool> updateStatus(String requestId, String status, {String? reason}) async {
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
      (updatedRequest) {
        final updatedList = state.pendingRequests
            .where((req) => req.id != requestId)
            .toList();
        state = state.copyWith(isLoading: false, pendingRequests: updatedList);
        return true;
      },
    );
  }
}

final adminVerificationNotifierProvider =
    StateNotifierProvider<AdminVerificationNotifier, AdminVerificationState>((ref) {
  return AdminVerificationNotifier(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../loads/domain/entities/load.dart';
import '../../../loads/presentation/providers/loads_provider.dart';

class AdminMonitoringState {
  final List<Load> allLoads;
  final bool isLoading;
  final String? error;

  AdminMonitoringState({
    this.allLoads = const [],
    this.isLoading = false,
    this.error,
  });

  AdminMonitoringState copyWith({
    List<Load>? allLoads,
    bool? isLoading,
    String? error,
  }) {
    return AdminMonitoringState(
      allLoads: allLoads ?? this.allLoads,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminMonitoringNotifier extends StateNotifier<AdminMonitoringState> {
  final Ref _ref;

  AdminMonitoringNotifier(this._ref) : super(AdminMonitoringState());

  Future<void> fetchAllLoads() async {
    state = state.copyWith(isLoading: true, error: null);

    // Reusing existing loadsNotifier but with administrative scope (fetching all)
    // In a real app, we'd have a specific Admin fetchAllLoads use case
    final result = await _ref.read(getLoadsUseCaseProvider)(status: null);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (loads) => state = state.copyWith(isLoading: false, allLoads: loads),
    );
  }

  Future<void> deleteLoad(String loadId) async {
    state = state.copyWith(isLoading: true);
    final result = await _ref.read(deleteLoadUseCaseProvider)(loadId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        final updatedLoads =
            state.allLoads.where((l) => l.id != loadId).toList();
        state = state.copyWith(isLoading: false, allLoads: updatedLoads);
      },
    );
  }
}

final adminMonitoringNotifierProvider =
    StateNotifierProvider<AdminMonitoringNotifier, AdminMonitoringState>((ref) {
  return AdminMonitoringNotifier(ref);
});

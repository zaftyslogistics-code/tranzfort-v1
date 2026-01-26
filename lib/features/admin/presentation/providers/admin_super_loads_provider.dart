import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../loads/domain/entities/load.dart';
import '../../../loads/presentation/providers/loads_provider.dart';

class AdminSuperLoadsState {
  final List<Load> superLoads;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  AdminSuperLoadsState({
    this.superLoads = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  AdminSuperLoadsState copyWith({
    List<Load>? superLoads,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return AdminSuperLoadsState(
      superLoads: superLoads ?? this.superLoads,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminSuperLoadsNotifier extends StateNotifier<AdminSuperLoadsState> {
  final Ref _ref;

  AdminSuperLoadsNotifier(this._ref) : super(AdminSuperLoadsState());

  Future<void> fetchSuperLoads({String? query}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query ?? state.searchQuery,
    );

    final effectiveQuery = (query ?? state.searchQuery).trim();

    final result = await _ref.read(getLoadsUseCaseProvider)(
          status: null,
          searchQuery: effectiveQuery.isEmpty ? null : effectiveQuery,
        );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (loads) {
        final filtered =
            loads.where((l) => l.isSuperLoad).toList(growable: false);
        state = state.copyWith(isLoading: false, superLoads: filtered);
      },
    );
  }

  Future<bool> deleteSuperLoad(String loadId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _ref.read(deleteLoadUseCaseProvider)(loadId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        final updated =
            state.superLoads.where((l) => l.id != loadId).toList(growable: false);
        state = state.copyWith(isLoading: false, superLoads: updated);

        _logAudit(action: 'super_load_deleted', entityId: loadId);
        return true;
      },
    );
  }

  Future<bool> cloneAndRepost(Load source) async {
    state = state.copyWith(isLoading: true, error: null);

    final userId = _ref.read(authNotifierProvider).user?.id;
    if (userId == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return false;
    }

    final now = DateTime.now();

    final payload = <String, dynamic>{
      'supplierId': userId,
      'isSuperLoad': true,
      'postedByAdminId': userId,
      'fromLocation': source.fromLocation,
      'fromCity': source.fromCity,
      'fromState': source.fromState,
      'fromLat': source.fromLat,
      'fromLng': source.fromLng,
      'toLocation': source.toLocation,
      'toCity': source.toCity,
      'toState': source.toState,
      'toLat': source.toLat,
      'toLng': source.toLng,
      'loadType': source.loadType,
      'truckTypeRequired': source.truckTypeRequired,
      'weight': source.weight,
      'price': source.price,
      'priceType': source.priceType,
      'paymentTerms': source.paymentTerms,
      'loadingDate': source.loadingDate?.toIso8601String(),
      'notes': source.notes,
      'contactPreferencesCall': source.contactPreferencesCall,
      'contactPreferencesChat': source.contactPreferencesChat,
      'expiresAt': now.add(const Duration(days: 90)).toIso8601String(),
    };

    final result = await _ref.read(createLoadUseCaseProvider)(payload);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (created) {
        final next = [created, ...state.superLoads];
        state = state.copyWith(isLoading: false, superLoads: next);

        _logAudit(action: 'super_load_cloned_reposted', entityId: created.id);
        return true;
      },
    );
  }

  Future<void> _logAudit({
    required String action,
    required String entityId,
  }) async {
    try {
      final adminId = _ref.read(authNotifierProvider).user?.id;
      if (adminId == null) return;

      await Supabase.instance.client.from('audit_logs').insert({
        'admin_id': adminId,
        'action': action,
        'entity_type': 'load',
        'entity_id': entityId,
      });
    } catch (_) {
      // Best-effort only.
    }
  }
}

final adminSuperLoadsNotifierProvider =
    StateNotifierProvider<AdminSuperLoadsNotifier, AdminSuperLoadsState>((ref) {
  return AdminSuperLoadsNotifier(ref);
});

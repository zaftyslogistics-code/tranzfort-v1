import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/deals_datasource.dart';
import '../../data/datasources/supabase_deals_datasource.dart';
import '../../data/repositories/deals_repository_impl.dart';
import '../../domain/entities/deal_truck_share.dart';
import '../../domain/repositories/deals_repository.dart';

final dealsDataSourceProvider = Provider<DealsDataSource>((ref) {
  return SupabaseDealsDataSource(Supabase.instance.client);
});

final dealsRepositoryProvider = Provider<DealsRepository>((ref) {
  final ds = ref.watch(dealsDataSourceProvider);
  return DealsRepositoryImpl(ds);
});

class DealsState {
  final DealTruckShare? deal;
  final bool isLoading;
  final String? error;
  final String? signedRcUrl;

  DealsState({
    this.deal,
    this.isLoading = false,
    this.error,
    this.signedRcUrl,
  });

  DealsState copyWith({
    DealTruckShare? deal,
    bool? isLoading,
    String? error,
    String? signedRcUrl,
  }) {
    return DealsState(
      deal: deal ?? this.deal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      signedRcUrl: signedRcUrl,
    );
  }
}

class DealsNotifier extends StateNotifier<DealsState> {
  final Ref _ref;

  DealsNotifier(this._ref) : super(DealsState());

  Future<void> fetchDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(dealsRepositoryProvider);
    final result = await repo.getDeal(
      loadId: loadId,
      supplierId: supplierId,
      truckerId: truckerId,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (deal) => state = state.copyWith(isLoading: false, deal: deal),
    );
  }

  Future<void> ensureDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? offerId,
    String? truckId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(dealsRepositoryProvider);
    final result = await repo.createOrUpdateDeal(
      loadId: loadId,
      supplierId: supplierId,
      truckerId: truckerId,
      offerId: offerId,
      truckId: truckId,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (deal) => state = state.copyWith(isLoading: false, deal: deal),
    );
  }

  Future<void> requestRc() async {
    final deal = state.deal;
    if (deal == null) return;

    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(dealsRepositoryProvider);
    final result =
        await repo.updateRcShareStatus(dealId: deal.id, status: 'requested');

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (updated) async {
        state = state.copyWith(isLoading: false, deal: updated);
        if (EnvConfig.enableAnalytics) {
          await AnalyticsService().trackBusinessEvent(
            'rc_requested',
            properties: {
              'load_id': updated.loadId,
            },
          );
        }

        // Best-effort notification to trucker.
        try {
          await Supabase.instance.client.rpc(
            'notify_rc_requested',
            params: {
              'p_deal_id': updated.id,
            },
          );
        } catch (_) {
          // ignore
        }
      },
    );
  }

  Future<void> approveRc() async {
    final deal = state.deal;
    if (deal == null) return;

    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(dealsRepositoryProvider);
    final result =
        await repo.updateRcShareStatus(dealId: deal.id, status: 'approved');

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (updated) async {
        state = state.copyWith(isLoading: false, deal: updated);
        if (EnvConfig.enableAnalytics) {
          await AnalyticsService().trackBusinessEvent(
            'rc_approved',
            properties: {
              'load_id': updated.loadId,
            },
          );
        }

        // Best-effort notification to supplier.
        try {
          await Supabase.instance.client.rpc(
            'notify_rc_approved',
            params: {
              'p_deal_id': updated.id,
            },
          );
        } catch (_) {
          // ignore
        }
      },
    );
  }

  Future<void> revokeRc() async {
    final deal = state.deal;
    if (deal == null) return;

    state = state.copyWith(isLoading: true, error: null);
    final repo = _ref.read(dealsRepositoryProvider);
    final result =
        await repo.updateRcShareStatus(dealId: deal.id, status: 'revoked');

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (updated) async {
        state = state.copyWith(isLoading: false, deal: updated);
        if (EnvConfig.enableAnalytics) {
          await AnalyticsService().trackBusinessEvent(
            'rc_revoked',
            properties: {
              'load_id': updated.loadId,
            },
          );
        }
      },
    );
  }

  Future<void> loadSignedRcUrl({int expiresInSeconds = 60 * 20}) async {
    final deal = state.deal;
    if (deal == null) return;
    if (deal.truckId == null) {
      state = state.copyWith(error: 'Truck not selected for this deal');
      return;
    }

    // Ensure we have the truck record locally (fleet is owned by trucker; suppliers will rely on policy)
    final supabase = Supabase.instance.client;

    try {
      state = state.copyWith(isLoading: true, error: null);
      final truckRow = await supabase
          .from('trucks')
          .select('rc_document_url')
          .eq('id', deal.truckId!)
          .single();

      final rcPath = truckRow['rc_document_url'] as String?;
      if (rcPath == null || rcPath.isEmpty) {
        state =
            state.copyWith(isLoading: false, error: 'RC document not uploaded');
        return;
      }

      final repo = _ref.read(dealsRepositoryProvider);
      final urlResult = await repo.getSignedRcUrl(
        truckId: deal.truckId!,
        rcPath: rcPath,
        expiresInSeconds: expiresInSeconds,
      );

      urlResult.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (url) => state = state.copyWith(isLoading: false, signedRcUrl: url),
      );
    } catch (e) {
      Logger.error('Failed to load signed RC url', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dealsNotifierProvider =
    StateNotifierProvider<DealsNotifier, DealsState>((ref) {
  return DealsNotifier(ref);
});

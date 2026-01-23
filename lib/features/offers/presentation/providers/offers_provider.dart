import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/offers_datasource.dart';
import '../../data/datasources/supabase_offers_datasource.dart';
import '../../data/repositories/offers_repository_impl.dart';
import '../../domain/entities/load_offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../../domain/usecases/create_offer.dart';
import '../../domain/usecases/list_offers_for_load.dart';
import '../../domain/usecases/update_offer.dart';

final offersDataSourceProvider = Provider<OffersDataSource>((ref) {
  return SupabaseOffersDataSource(Supabase.instance.client);
});

final offersRepositoryProvider = Provider<OffersRepository>((ref) {
  final ds = ref.watch(offersDataSourceProvider);
  return OffersRepositoryImpl(ds);
});

final createOfferUseCaseProvider = Provider((ref) {
  final repo = ref.watch(offersRepositoryProvider);
  return CreateOffer(repo);
});

final listOffersForLoadUseCaseProvider = Provider((ref) {
  final repo = ref.watch(offersRepositoryProvider);
  return ListOffersForLoad(repo);
});

final updateOfferUseCaseProvider = Provider((ref) {
  final repo = ref.watch(offersRepositoryProvider);
  return UpdateOffer(repo);
});

class OffersState {
  final List<LoadOffer> offers;
  final bool isLoading;
  final String? error;

  OffersState({
    this.offers = const [],
    this.isLoading = false,
    this.error,
  });

  OffersState copyWith({
    List<LoadOffer>? offers,
    bool? isLoading,
    String? error,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OffersNotifier extends StateNotifier<OffersState> {
  final Ref _ref;

  OffersNotifier(this._ref) : super(OffersState());

  Future<void> fetchOffersForLoad(String loadId) async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(listOffersForLoadUseCaseProvider);
    final result = await useCase(loadId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (offers) => state = state.copyWith(isLoading: false, offers: offers),
    );
  }

  Future<LoadOffer?> createOffer({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(createOfferUseCaseProvider);
    final result = await useCase(
      loadId: loadId,
      supplierId: supplierId,
      truckerId: truckerId,
      truckId: truckId,
      price: price,
      message: message,
    );

    return result.fold(
      (failure) {
        Logger.error('Offer create failed: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (offer) {
        state = state.copyWith(isLoading: false, offers: [offer, ...state.offers]);
        return offer;
      },
    );
  }

  Future<LoadOffer?> updateOffer({
    required String offerId,
    required Map<String, dynamic> updates,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final useCase = _ref.read(updateOfferUseCaseProvider);
    final result = await useCase(offerId: offerId, updates: updates);

    return result.fold(
      (failure) {
        Logger.error('Offer update failed: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (offer) {
        final updatedList = state.offers
            .map((o) => o.id == offer.id ? offer : o)
            .toList(growable: false);
        state = state.copyWith(isLoading: false, offers: updatedList);
        return offer;
      },
    );
  }
}

final offersNotifierProvider = StateNotifierProvider<OffersNotifier, OffersState>((ref) {
  return OffersNotifier(ref);
});

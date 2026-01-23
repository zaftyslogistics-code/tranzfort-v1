import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/load_offer_model.dart';
import 'offers_datasource.dart';

class SupabaseOffersDataSource implements OffersDataSource {
  final SupabaseClient _client;

  SupabaseOffersDataSource(this._client);

  @override
  Future<LoadOfferModel> createOffer({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  }) async {
    try {
      final payload = {
        'load_id': loadId,
        'supplier_id': supplierId,
        'trucker_id': truckerId,
        'truck_id': truckId,
        'price': price,
        'message': message,
        'status': 'proposed',
      };

      final inserted = await _client
          .from('load_offers')
          .insert(payload)
          .select('*')
          .single();

      // Best-effort notification to supplier.
      try {
        await _client.rpc(
          'notify_offer_created',
          params: {
            'p_offer_id': inserted['id'],
          },
        );
      } catch (e) {
        Logger.warning('Failed to send offer_created notification: $e');
      }

      return LoadOfferModel.fromJson(inserted);
    } catch (e) {
      Logger.error('Failed to create offer', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<LoadOfferModel>> listOffersForLoad(String loadId) async {
    try {
      final rows = await _client
          .from('load_offers')
          .select('*')
          .eq('load_id', loadId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((json) => LoadOfferModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to list offers', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LoadOfferModel> updateOffer({
    required String offerId,
    Map<String, dynamic> updates = const {},
  }) async {
    try {
      final payload = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updated = await _client
          .from('load_offers')
          .update(payload)
          .eq('id', offerId)
          .select('*')
          .single();

      return LoadOfferModel.fromJson(updated);
    } catch (e) {
      Logger.error('Failed to update offer', error: e);
      throw ServerException(e.toString());
    }
  }
}

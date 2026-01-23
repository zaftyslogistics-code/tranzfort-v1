import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/deal_truck_share_model.dart';
import 'deals_datasource.dart';

class SupabaseDealsDataSource implements DealsDataSource {
  final SupabaseClient _client;

  SupabaseDealsDataSource(this._client);

  @override
  Future<DealTruckShareModel?> getDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
  }) async {
    try {
      final row = await _client
          .from('deal_truck_shares')
          .select('*')
          .eq('load_id', loadId)
          .eq('supplier_id', supplierId)
          .eq('trucker_id', truckerId)
          .maybeSingle();

      if (row == null) return null;
      return DealTruckShareModel.fromJson(row);
    } catch (e) {
      Logger.error('Failed to get deal', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DealTruckShareModel> createOrUpdateDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? offerId,
    String? truckId,
  }) async {
    try {
      final payload = {
        'load_id': loadId,
        'supplier_id': supplierId,
        'trucker_id': truckerId,
        'offer_id': offerId,
        'truck_id': truckId,
      };

      final inserted = await _client
          .from('deal_truck_shares')
          .upsert(
            payload,
            onConflict: 'load_id,supplier_id,trucker_id',
          )
          .select('*')
          .single();

      return DealTruckShareModel.fromJson(inserted);
    } catch (e) {
      Logger.error('Failed to create/update deal', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DealTruckShareModel> updateRcShareStatus({
    required String dealId,
    required String status,
  }) async {
    try {
      final updated = await _client
          .from('deal_truck_shares')
          .update({
            'rc_share_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dealId)
          .select('*')
          .single();

      return DealTruckShareModel.fromJson(updated);
    } catch (e) {
      Logger.error('Failed to update rc share status', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> getSignedRcUrl({
    required String truckId,
    required String rcPath,
    required int expiresInSeconds,
  }) async {
    try {
      final signedUrl = await _client.storage
          .from('fleet-documents')
          .createSignedUrl(rcPath, expiresInSeconds);
      return signedUrl;
    } catch (e) {
      Logger.error('Failed to create signed RC url', error: e);
      throw ServerException(e.toString());
    }
  }
}

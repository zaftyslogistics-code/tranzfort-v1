import '../models/deal_truck_share_model.dart';

abstract class DealsDataSource {
  Future<DealTruckShareModel?> getDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
  });

  Future<DealTruckShareModel> createOrUpdateDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? offerId,
    String? truckId,
  });

  Future<DealTruckShareModel> updateRcShareStatus({
    required String dealId,
    required String status,
  });

  Future<String> getSignedRcUrl({
    required String truckId,
    required String rcPath,
    required int expiresInSeconds,
  });
}

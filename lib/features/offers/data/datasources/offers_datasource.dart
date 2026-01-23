import '../models/load_offer_model.dart';

abstract class OffersDataSource {
  Future<LoadOfferModel> createOffer({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  });

  Future<List<LoadOfferModel>> listOffersForLoad(String loadId);

  Future<LoadOfferModel> updateOffer({
    required String offerId,
    Map<String, dynamic> updates,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load_offer.dart';

abstract class OffersRepository {
  Future<Either<Failure, LoadOffer>> createOffer({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  });

  Future<Either<Failure, List<LoadOffer>>> listOffersForLoad(String loadId);

  Future<Either<Failure, LoadOffer>> updateOffer({
    required String offerId,
    required Map<String, dynamic> updates,
  });
}

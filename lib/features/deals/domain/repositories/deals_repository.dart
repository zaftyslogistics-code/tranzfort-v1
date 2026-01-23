import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/deal_truck_share.dart';

abstract class DealsRepository {
  Future<Either<Failure, DealTruckShare?>> getDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
  });

  Future<Either<Failure, DealTruckShare>> createOrUpdateDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? offerId,
    String? truckId,
  });

  Future<Either<Failure, DealTruckShare>> updateRcShareStatus({
    required String dealId,
    required String status,
  });

  Future<Either<Failure, String>> getSignedRcUrl({
    required String truckId,
    required String rcPath,
    required int expiresInSeconds,
  });
}

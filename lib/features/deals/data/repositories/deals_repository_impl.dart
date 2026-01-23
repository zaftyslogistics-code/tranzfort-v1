import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/deal_truck_share.dart';
import '../../domain/repositories/deals_repository.dart';
import '../datasources/deals_datasource.dart';

class DealsRepositoryImpl implements DealsRepository {
  final DealsDataSource _dataSource;

  DealsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, DealTruckShare?>> getDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
  }) async {
    try {
      final deal = await _dataSource.getDeal(
        loadId: loadId,
        supplierId: supplierId,
        truckerId: truckerId,
      );
      return Right(deal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DealTruckShare>> createOrUpdateDeal({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? offerId,
    String? truckId,
  }) async {
    try {
      final deal = await _dataSource.createOrUpdateDeal(
        loadId: loadId,
        supplierId: supplierId,
        truckerId: truckerId,
        offerId: offerId,
        truckId: truckId,
      );
      return Right(deal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DealTruckShare>> updateRcShareStatus({
    required String dealId,
    required String status,
  }) async {
    try {
      final deal = await _dataSource.updateRcShareStatus(
        dealId: dealId,
        status: status,
      );
      return Right(deal);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getSignedRcUrl({
    required String truckId,
    required String rcPath,
    required int expiresInSeconds,
  }) async {
    try {
      final url = await _dataSource.getSignedRcUrl(
        truckId: truckId,
        rcPath: rcPath,
        expiresInSeconds: expiresInSeconds,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

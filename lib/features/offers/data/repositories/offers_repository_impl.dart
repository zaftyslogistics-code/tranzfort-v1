import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/load_offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersDataSource _dataSource;

  OffersRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, LoadOffer>> createOffer({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  }) async {
    try {
      final offer = await _dataSource.createOffer(
        loadId: loadId,
        supplierId: supplierId,
        truckerId: truckerId,
        truckId: truckId,
        price: price,
        message: message,
      );
      return Right(offer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LoadOffer>>> listOffersForLoad(
      String loadId) async {
    try {
      final offers = await _dataSource.listOffersForLoad(loadId);
      return Right(offers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoadOffer>> updateOffer({
    required String offerId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final offer = await _dataSource.updateOffer(
        offerId: offerId,
        updates: updates,
      );
      return Right(offer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

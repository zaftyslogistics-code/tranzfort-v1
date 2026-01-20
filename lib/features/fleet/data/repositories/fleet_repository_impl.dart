import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/truck.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../datasources/fleet_datasource.dart';

class FleetRepositoryImpl implements FleetRepository {
  final FleetDataSource _dataSource;

  FleetRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Truck>>> getTrucks() async {
    try {
      final trucks = await _dataSource.getTrucks();
      return Right(trucks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Truck>> addTruck(Map<String, dynamic> truckData, {XFile? rcDocument, XFile? insuranceDocument}) async {
    try {
      final truck = await _dataSource.addTruck(truckData, rcDocument: rcDocument, insuranceDocument: insuranceDocument);
      return Right(truck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Truck>> updateTruck(String id, Map<String, dynamic> updates, {XFile? rcDocument, XFile? insuranceDocument}) async {
    try {
      final truck = await _dataSource.updateTruck(id, updates, rcDocument: rcDocument, insuranceDocument: insuranceDocument);
      return Right(truck);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTruck(String id) async {
    try {
      await _dataSource.deleteTruck(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

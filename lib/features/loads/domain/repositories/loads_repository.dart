import 'package:dartz/dartz.dart';
import '../entities/load.dart';
import '../entities/truck_type.dart';
import '../entities/material_type.dart';
import '../../../../core/errors/failures.dart';

abstract class LoadsRepository {
  Future<Either<Failure, Load>> createLoad(Map<String, dynamic> loadData);

  Future<Either<Failure, List<Load>>> getLoads({
    String? status,
    String? supplierId,
    String? searchQuery,
  });

  Future<Either<Failure, Load?>> getLoadById(String id);

  Future<Either<Failure, Load>> updateLoad(
    String id,
    Map<String, dynamic> updates,
  );

  Future<Either<Failure, void>> deleteLoad(String id);

  Future<Either<Failure, void>> incrementViewCount(String id);

  Future<Either<Failure, List<TruckType>>> getTruckTypes();

  Future<Either<Failure, List<MaterialType>>> getMaterialTypes();
}

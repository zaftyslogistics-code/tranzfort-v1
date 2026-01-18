import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/truck_type.dart';
import '../repositories/loads_repository.dart';

class GetTruckTypes {
  final LoadsRepository repository;

  GetTruckTypes(this.repository);

  Future<Either<Failure, List<TruckType>>> call() async {
    return await repository.getTruckTypes();
  }
}

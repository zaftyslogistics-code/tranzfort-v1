import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load.dart';
import '../repositories/loads_repository.dart';

class GetLoads {
  final LoadsRepository repository;

  GetLoads(this.repository);

  Future<Either<Failure, List<Load>>> call({
    String? status,
    String? supplierId,
  }) async {
    return await repository.getLoads(
      status: status,
      supplierId: supplierId,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load.dart';
import '../repositories/loads_repository.dart';

class UpdateLoad {
  final LoadsRepository repository;

  UpdateLoad(this.repository);

  Future<Either<Failure, Load>> call(
    String id,
    Map<String, dynamic> updates,
  ) async {
    return await repository.updateLoad(id, updates);
  }
}

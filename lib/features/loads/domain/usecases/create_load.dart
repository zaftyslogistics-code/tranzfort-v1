import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load.dart';
import '../repositories/loads_repository.dart';

class CreateLoad {
  final LoadsRepository repository;

  CreateLoad(this.repository);

  Future<Either<Failure, Load>> call(Map<String, dynamic> loadData) async {
    return await repository.createLoad(loadData);
  }
}

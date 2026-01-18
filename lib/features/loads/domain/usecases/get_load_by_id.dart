import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load.dart';
import '../repositories/loads_repository.dart';

class GetLoadById {
  final LoadsRepository repository;

  GetLoadById(this.repository);

  Future<Either<Failure, Load?>> call(String id) async {
    return await repository.getLoadById(id);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/loads_repository.dart';

class DeleteLoad {
  final LoadsRepository repository;

  DeleteLoad(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteLoad(id);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/material_type.dart';
import '../repositories/loads_repository.dart';

class GetMaterialTypes {
  final LoadsRepository repository;

  GetMaterialTypes(this.repository);

  Future<Either<Failure, List<MaterialType>>> call() async {
    return await repository.getMaterialTypes();
  }
}

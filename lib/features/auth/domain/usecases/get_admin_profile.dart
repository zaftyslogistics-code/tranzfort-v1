import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin.dart';
import '../repositories/auth_repository.dart';

class GetAdminProfile {
  final AuthRepository repository;

  GetAdminProfile(this.repository);

  Future<Either<Failure, Admin?>> call(String userId) {
    return repository.getAdminProfile(userId);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    return await repository.updateProfile(userId, updates);
  }
}

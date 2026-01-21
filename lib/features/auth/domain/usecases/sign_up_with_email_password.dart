import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return repository.signUpWithEmailPassword(email, password);
  }
}

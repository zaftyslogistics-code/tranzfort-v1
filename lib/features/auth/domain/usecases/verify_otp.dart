import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<Either<Failure, User>> call(
    String mobileNumber,
    String otp,
  ) async {
    return await repository.verifyOtp(mobileNumber, otp);
  }
}

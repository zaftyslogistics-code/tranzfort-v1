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
    throw UnsupportedError('OTP login has been removed');
  }
}

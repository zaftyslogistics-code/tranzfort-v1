import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(
    String mobileNumber,
    String countryCode,
  );
  
  Future<Either<Failure, User>> verifyOtp(
    String mobileNumber,
    String otp,
  );
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, User>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  );
}

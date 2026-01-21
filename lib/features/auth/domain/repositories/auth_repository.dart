import 'package:dartz/dartz.dart';
import '../entities/admin.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword(
    String email,
    String password,
  );

  Future<Either<Failure, User>> signInWithEmailPassword(
    String email,
    String password,
  );
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, User>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  );

  Future<Either<Failure, Admin?>> getAdminProfile(String userId);
}

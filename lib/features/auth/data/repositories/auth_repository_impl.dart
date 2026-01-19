import 'package:dartz/dartz.dart';
import '../../domain/entities/admin.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> sendOtp(
    String mobileNumber,
    String countryCode,
  ) async {
    try {
      await dataSource.sendOtp(mobileNumber, countryCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp(
    String mobileNumber,
    String otp,
  ) async {
    try {
      final userModel = await dataSource.verifyOtp(mobileNumber, otp);
      return Right(_modelToEntity(userModel));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await dataSource.getCurrentUser();
      if (userModel == null) return const Right(null);
      return Right(_modelToEntity(userModel));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final userModel = await dataSource.updateProfile(userId, updates);
      return Right(_modelToEntity(userModel));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Admin?>> getAdminProfile(String userId) async {
    try {
      final adminModel = await dataSource.getAdminProfile(userId);
      if (adminModel == null) return const Right(null);
      return Right(Admin(
        id: adminModel.id,
        role: adminModel.role,
        fullName: adminModel.fullName,
        createdAt: adminModel.createdAt,
        updatedAt: adminModel.updatedAt,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  User _modelToEntity(userModel) {
    return User(
      id: userModel.id,
      mobileNumber: userModel.mobileNumber,
      countryCode: userModel.countryCode,
      name: userModel.name,
      isSupplierEnabled: userModel.isSupplierEnabled,
      isTruckerEnabled: userModel.isTruckerEnabled,
      supplierVerificationStatus: userModel.supplierVerificationStatus,
      truckerVerificationStatus: userModel.truckerVerificationStatus,
      createdAt: userModel.createdAt,
      lastLoginAt: userModel.lastLoginAt,
    );
  }
}

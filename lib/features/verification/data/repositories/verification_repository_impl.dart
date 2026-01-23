import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/supabase_verification_datasource.dart';
import '../models/verification_request_model.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final dynamic _dataSource;

  VerificationRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, VerificationRequestModel>> createVerificationRequest({
    required String roleType,
    required String documentType,
    String? documentNumber,
    String? companyName,
    String? vehicleNumber,
    required XFile front,
    required XFile back,
  }) async {
    try {
      final request = await _dataSource.createVerificationRequest(
        roleType: roleType,
        documentType: documentType,
        documentNumber: documentNumber,
        companyName: companyName,
        vehicleNumber: vehicleNumber,
        front: front,
        back: back,
      );
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerificationRequestModel>>>
      getPendingVerificationRequests() async {
    try {
      final requests = await _dataSource.getPendingVerificationRequests();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerificationRequestModel>> updateVerificationStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final request = await _dataSource.updateVerificationStatus(
        requestId: requestId,
        status: status,
        rejectionReason: rejectionReason,
      );
      return Right(request);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

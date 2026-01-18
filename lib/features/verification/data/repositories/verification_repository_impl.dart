import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/supabase_verification_datasource.dart';
import '../models/verification_request_model.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final SupabaseVerificationDataSource _dataSource;

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
      return Left(ServerFailure(e.toString()));
    }
  }
}

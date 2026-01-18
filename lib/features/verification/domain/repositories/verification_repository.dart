import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/verification_request_model.dart';

abstract class VerificationRepository {
  Future<Either<Failure, VerificationRequestModel>> createVerificationRequest({
    required String roleType,
    required String documentType,
    String? documentNumber,
    String? companyName,
    String? vehicleNumber,
    required XFile front,
    required XFile back,
  });
}

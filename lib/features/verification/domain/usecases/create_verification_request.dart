import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/verification_request_model.dart';
import '../repositories/verification_repository.dart';

class CreateVerificationRequest {
  final VerificationRepository repository;

  CreateVerificationRequest(this.repository);

  Future<Either<Failure, VerificationRequestModel>> call({
    required String roleType,
    required String documentType,
    String? documentNumber,
    String? companyName,
    String? vehicleNumber,
    required XFile front,
    required XFile back,
  }) {
    return repository.createVerificationRequest(
      roleType: roleType,
      documentType: documentType,
      documentNumber: documentNumber,
      companyName: companyName,
      vehicleNumber: vehicleNumber,
      front: front,
      back: back,
    );
  }
}

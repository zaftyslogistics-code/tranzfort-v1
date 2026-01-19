import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/verification_request_model.dart';
import '../repositories/verification_repository.dart';

class UpdateVerificationStatus {
  final VerificationRepository repository;

  UpdateVerificationStatus(this.repository);

  Future<Either<Failure, VerificationRequestModel>> call({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) {
    return repository.updateVerificationStatus(
      requestId: requestId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}

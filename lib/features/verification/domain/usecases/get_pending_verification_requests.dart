import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/verification_request_model.dart';
import '../repositories/verification_repository.dart';

class GetPendingVerificationRequests {
  final VerificationRepository repository;

  GetPendingVerificationRequests(this.repository);

  Future<Either<Failure, List<VerificationRequestModel>>> call() {
    return repository.getPendingVerificationRequests();
  }
}

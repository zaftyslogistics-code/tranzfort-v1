import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load_offer.dart';
import '../repositories/offers_repository.dart';

class CreateOffer {
  final OffersRepository repository;

  CreateOffer(this.repository);

  Future<Either<Failure, LoadOffer>> call({
    required String loadId,
    required String supplierId,
    required String truckerId,
    String? truckId,
    double? price,
    String? message,
  }) {
    return repository.createOffer(
      loadId: loadId,
      supplierId: supplierId,
      truckerId: truckerId,
      truckId: truckId,
      price: price,
      message: message,
    );
  }
}

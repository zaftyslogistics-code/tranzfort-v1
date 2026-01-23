import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load_offer.dart';
import '../repositories/offers_repository.dart';

class UpdateOffer {
  final OffersRepository repository;

  UpdateOffer(this.repository);

  Future<Either<Failure, LoadOffer>> call({
    required String offerId,
    required Map<String, dynamic> updates,
  }) {
    return repository.updateOffer(offerId: offerId, updates: updates);
  }
}

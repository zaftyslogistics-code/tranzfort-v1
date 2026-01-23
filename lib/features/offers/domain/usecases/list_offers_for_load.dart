import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/load_offer.dart';
import '../repositories/offers_repository.dart';

class ListOffersForLoad {
  final OffersRepository repository;

  ListOffersForLoad(this.repository);

  Future<Either<Failure, List<LoadOffer>>> call(String loadId) {
    return repository.listOffersForLoad(loadId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/truck.dart';

abstract class FleetRepository {
  Future<Either<Failure, List<Truck>>> getTrucks();
  Future<Either<Failure, Truck>> addTruck(Map<String, dynamic> truckData, {XFile? rcDocument, XFile? insuranceDocument});
  Future<Either<Failure, Truck>> updateTruck(String id, Map<String, dynamic> updates, {XFile? rcDocument, XFile? insuranceDocument});
  Future<Either<Failure, void>> deleteTruck(String id);
}

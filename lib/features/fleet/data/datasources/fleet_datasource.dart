import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/truck_model.dart';

abstract class FleetDataSource {
  Future<List<TruckModel>> getTrucks({String? transporterId});
  Future<TruckModel> addTruck(Map<String, dynamic> truckData, {XFile? rcDocument, XFile? insuranceDocument});
  Future<TruckModel> updateTruck(String id, Map<String, dynamic> updates, {XFile? rcDocument, XFile? insuranceDocument});
  Future<void> deleteTruck(String id);
}

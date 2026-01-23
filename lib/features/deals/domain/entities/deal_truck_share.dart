import 'package:equatable/equatable.dart';

class DealTruckShare extends Equatable {
  final String id;
  final String? offerId;
  final String loadId;
  final String supplierId;
  final String truckerId;
  final String? truckId;
  final String rcShareStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DealTruckShare({
    required this.id,
    this.offerId,
    required this.loadId,
    required this.supplierId,
    required this.truckerId,
    this.truckId,
    required this.rcShareStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        offerId,
        loadId,
        supplierId,
        truckerId,
        truckId,
        rcShareStatus,
        createdAt,
        updatedAt,
      ];
}

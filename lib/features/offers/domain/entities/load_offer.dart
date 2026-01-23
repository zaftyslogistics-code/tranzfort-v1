import 'package:equatable/equatable.dart';

class LoadOffer extends Equatable {
  final String id;
  final String loadId;
  final String supplierId;
  final String truckerId;
  final String? truckId;
  final double? price;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoadOffer({
    required this.id,
    required this.loadId,
    required this.supplierId,
    required this.truckerId,
    this.truckId,
    this.price,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        loadId,
        supplierId,
        truckerId,
        truckId,
        price,
        message,
        status,
        createdAt,
        updatedAt,
      ];
}

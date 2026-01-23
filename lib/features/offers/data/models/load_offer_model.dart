import '../../domain/entities/load_offer.dart';

class LoadOfferModel extends LoadOffer {
  const LoadOfferModel({
    required super.id,
    required super.loadId,
    required super.supplierId,
    required super.truckerId,
    super.truckId,
    super.price,
    super.message,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LoadOfferModel.fromJson(Map<String, dynamic> json) {
    return LoadOfferModel(
      id: json['id'] as String,
      loadId: json['load_id'] as String,
      supplierId: json['supplier_id'] as String,
      truckerId: json['trucker_id'] as String,
      truckId: json['truck_id'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      message: json['message'] as String?,
      status: (json['status'] as String?) ?? 'proposed',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'load_id': loadId,
      'supplier_id': supplierId,
      'trucker_id': truckerId,
      'truck_id': truckId,
      'price': price,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

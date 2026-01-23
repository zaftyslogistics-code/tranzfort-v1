import '../../domain/entities/deal_truck_share.dart';

class DealTruckShareModel extends DealTruckShare {
  const DealTruckShareModel({
    required super.id,
    super.offerId,
    required super.loadId,
    required super.supplierId,
    required super.truckerId,
    super.truckId,
    required super.rcShareStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DealTruckShareModel.fromJson(Map<String, dynamic> json) {
    return DealTruckShareModel(
      id: json['id'] as String,
      offerId: json['offer_id'] as String?,
      loadId: json['load_id'] as String,
      supplierId: json['supplier_id'] as String,
      truckerId: json['trucker_id'] as String,
      truckId: json['truck_id'] as String?,
      rcShareStatus: (json['rc_share_status'] as String?) ?? 'not_requested',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_id': offerId,
      'load_id': loadId,
      'supplier_id': supplierId,
      'trucker_id': truckerId,
      'truck_id': truckId,
      'rc_share_status': rcShareStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

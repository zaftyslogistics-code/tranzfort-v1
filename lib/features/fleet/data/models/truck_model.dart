import '../../domain/entities/truck.dart';

class TruckModel extends Truck {
  const TruckModel({
    required String id,
    required String truckNumber,
    required String truckType,
    required double capacity,
    String? rcDocumentUrl,
    String? insuranceDocumentUrl,
    DateTime? rcExpiryDate,
    DateTime? insuranceExpiryDate,
    bool isActive = true,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          truckNumber: truckNumber,
          truckType: truckType,
          capacity: capacity,
          rcDocumentUrl: rcDocumentUrl,
          insuranceDocumentUrl: insuranceDocumentUrl,
          rcExpiryDate: rcExpiryDate,
          insuranceExpiryDate: insuranceExpiryDate,
          isActive: isActive,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory TruckModel.fromJson(Map<String, dynamic> json) {
    return TruckModel(
      id: json['id'] as String,
      truckNumber: json['truck_number'] as String,
      truckType: json['truck_type'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      rcDocumentUrl: json['rc_document_url'] as String?,
      insuranceDocumentUrl: json['insurance_document_url'] as String?,
      rcExpiryDate: json['rc_expiry_date'] != null
          ? DateTime.parse(json['rc_expiry_date'] as String)
          : null,
      insuranceExpiryDate: json['insurance_expiry_date'] != null
          ? DateTime.parse(json['insurance_expiry_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'truck_number': truckNumber,
      'truck_type': truckType,
      'capacity': capacity,
      'rc_document_url': rcDocumentUrl,
      'insurance_document_url': insuranceDocumentUrl,
      'rc_expiry_date': rcExpiryDate?.toIso8601String(),
      'insurance_expiry_date': insuranceExpiryDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

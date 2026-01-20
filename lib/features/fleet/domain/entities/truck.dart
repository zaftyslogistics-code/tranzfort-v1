import 'package:equatable/equatable.dart';

class Truck extends Equatable {
  final String id;
  final String truckNumber;
  final String truckType;
  final double capacity;
  final String? rcDocumentUrl;
  final String? insuranceDocumentUrl;
  final DateTime? rcExpiryDate;
  final DateTime? insuranceExpiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Truck({
    required this.id,
    required this.truckNumber,
    required this.truckType,
    required this.capacity,
    this.rcDocumentUrl,
    this.insuranceDocumentUrl,
    this.rcExpiryDate,
    this.insuranceExpiryDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Truck copyWith({
    String? id,
    String? truckNumber,
    String? truckType,
    double? capacity,
    String? rcDocumentUrl,
    String? insuranceDocumentUrl,
    DateTime? rcExpiryDate,
    DateTime? insuranceExpiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Truck(
      id: id ?? this.id,
      truckNumber: truckNumber ?? this.truckNumber,
      truckType: truckType ?? this.truckType,
      capacity: capacity ?? this.capacity,
      rcDocumentUrl: rcDocumentUrl ?? this.rcDocumentUrl,
      insuranceDocumentUrl: insuranceDocumentUrl ?? this.insuranceDocumentUrl,
      rcExpiryDate: rcExpiryDate ?? this.rcExpiryDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        truckNumber,
        truckType,
        capacity,
        rcDocumentUrl,
        insuranceDocumentUrl,
        rcExpiryDate,
        insuranceExpiryDate,
        isActive,
        createdAt,
        updatedAt,
      ];

  // Helper methods for UI
  bool get isRcExpiringSoon {
    if (rcExpiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = rcExpiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isInsuranceExpiringSoon {
    if (insuranceExpiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = insuranceExpiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isRcExpired {
    if (rcExpiryDate == null) return false;
    return DateTime.now().isAfter(rcExpiryDate!);
  }

  bool get isInsuranceExpired {
    if (insuranceExpiryDate == null) return false;
    return DateTime.now().isAfter(insuranceExpiryDate!);
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (isRcExpired || isInsuranceExpired) return 'Documents Expired';
    if (isRcExpiringSoon || isInsuranceExpiringSoon) return 'Expiring Soon';
    return 'Active';
  }
}

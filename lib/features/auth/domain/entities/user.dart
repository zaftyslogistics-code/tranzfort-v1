import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String mobileNumber;
  final String countryCode;
  final String? name;
  final bool isSupplierEnabled;
  final bool isTruckerEnabled;
  final String supplierVerificationStatus;
  final String truckerVerificationStatus;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.mobileNumber,
    required this.countryCode,
    this.name,
    required this.isSupplierEnabled,
    required this.isTruckerEnabled,
    required this.supplierVerificationStatus,
    required this.truckerVerificationStatus,
    this.preferences = const {},
    required this.createdAt,
    required this.lastLoginAt,
  });

  bool get isSupplierVerified => supplierVerificationStatus == 'verified';
  bool get isTruckerVerified => truckerVerificationStatus == 'verified';
  bool get hasName => name != null && name!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        mobileNumber,
        countryCode,
        name,
        isSupplierEnabled,
        isTruckerEnabled,
        supplierVerificationStatus,
        truckerVerificationStatus,
        preferences,
        createdAt,
        lastLoginAt,
      ];
}

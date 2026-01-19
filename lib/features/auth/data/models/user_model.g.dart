// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      mobileNumber: json['mobile_number'] as String,
      countryCode: json['country_code'] as String? ?? '+91',
      name: json['name'] as String?,
      isSupplierEnabled: json['is_supplier_enabled'] as bool? ?? false,
      isTruckerEnabled: json['is_trucker_enabled'] as bool? ?? false,
      supplierVerificationStatus:
          json['supplier_verification_status'] as String? ?? 'unverified',
      truckerVerificationStatus:
          json['trucker_verification_status'] as String? ?? 'unverified',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: DateTime.parse(json['last_login_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile_number': instance.mobileNumber,
      'country_code': instance.countryCode,
      'name': instance.name,
      'is_supplier_enabled': instance.isSupplierEnabled,
      'is_trucker_enabled': instance.isTruckerEnabled,
      'supplier_verification_status': instance.supplierVerificationStatus,
      'trucker_verification_status': instance.truckerVerificationStatus,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

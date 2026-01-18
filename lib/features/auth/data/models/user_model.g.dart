// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      mobileNumber: json['mobileNumber'] as String,
      countryCode: json['countryCode'] as String? ?? '+91',
      name: json['name'] as String?,
      isSupplierEnabled: json['isSupplierEnabled'] as bool? ?? false,
      isTruckerEnabled: json['isTruckerEnabled'] as bool? ?? false,
      supplierVerificationStatus:
          json['supplierVerificationStatus'] as String? ?? 'unverified',
      truckerVerificationStatus:
          json['truckerVerificationStatus'] as String? ?? 'unverified',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobileNumber': instance.mobileNumber,
      'countryCode': instance.countryCode,
      'name': instance.name,
      'isSupplierEnabled': instance.isSupplierEnabled,
      'isTruckerEnabled': instance.isTruckerEnabled,
      'supplierVerificationStatus': instance.supplierVerificationStatus,
      'truckerVerificationStatus': instance.truckerVerificationStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

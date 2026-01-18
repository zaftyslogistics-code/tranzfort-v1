// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoadModelImpl _$$LoadModelImplFromJson(Map<String, dynamic> json) =>
    _$LoadModelImpl(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      fromLocation: json['fromLocation'] as String,
      fromCity: json['fromCity'] as String,
      fromState: json['fromState'] as String?,
      toLocation: json['toLocation'] as String,
      toCity: json['toCity'] as String,
      toState: json['toState'] as String?,
      loadType: json['loadType'] as String,
      truckTypeRequired: json['truckTypeRequired'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['priceType'] as String? ?? 'negotiable',
      paymentTerms: json['paymentTerms'] as String?,
      loadingDate: json['loadingDate'] == null
          ? null
          : DateTime.parse(json['loadingDate'] as String),
      notes: json['notes'] as String?,
      contactPreferencesCall: json['contactPreferencesCall'] as bool? ?? true,
      contactPreferencesChat: json['contactPreferencesChat'] as bool? ?? true,
      status: json['status'] as String? ?? 'active',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LoadModelImplToJson(_$LoadModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'fromLocation': instance.fromLocation,
      'fromCity': instance.fromCity,
      'fromState': instance.fromState,
      'toLocation': instance.toLocation,
      'toCity': instance.toCity,
      'toState': instance.toState,
      'loadType': instance.loadType,
      'truckTypeRequired': instance.truckTypeRequired,
      'weight': instance.weight,
      'price': instance.price,
      'priceType': instance.priceType,
      'paymentTerms': instance.paymentTerms,
      'loadingDate': instance.loadingDate?.toIso8601String(),
      'notes': instance.notes,
      'contactPreferencesCall': instance.contactPreferencesCall,
      'contactPreferencesChat': instance.contactPreferencesChat,
      'status': instance.status,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

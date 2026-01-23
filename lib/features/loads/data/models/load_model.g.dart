// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoadModelImpl _$$LoadModelImplFromJson(Map<String, dynamic> json) =>
    _$LoadModelImpl(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      fromLocation: json['from_location'] as String,
      fromCity: json['from_city'] as String,
      fromState: json['from_state'] as String?,
      fromLat: (json['from_lat'] as num?)?.toDouble(),
      fromLng: (json['from_lng'] as num?)?.toDouble(),
      toLocation: json['to_location'] as String,
      toCity: json['to_city'] as String,
      toState: json['to_state'] as String?,
      toLat: (json['to_lat'] as num?)?.toDouble(),
      toLng: (json['to_lng'] as num?)?.toDouble(),
      loadType: json['load_type'] as String,
      truckTypeRequired: json['truck_type_required'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['price_type'] as String? ?? 'negotiable',
      paymentTerms: json['payment_terms'] as String?,
      loadingDate: json['loading_date'] == null
          ? null
          : DateTime.parse(json['loading_date'] as String),
      notes: json['notes'] as String?,
      contactPreferencesCall: json['contact_preferences_call'] as bool? ?? true,
      contactPreferencesChat: json['contact_preferences_chat'] as bool? ?? true,
      status: json['status'] as String? ?? 'active',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$LoadModelImplToJson(_$LoadModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplier_id': instance.supplierId,
      'from_location': instance.fromLocation,
      'from_city': instance.fromCity,
      'from_state': instance.fromState,
      'from_lat': instance.fromLat,
      'from_lng': instance.fromLng,
      'to_location': instance.toLocation,
      'to_city': instance.toCity,
      'to_state': instance.toState,
      'to_lat': instance.toLat,
      'to_lng': instance.toLng,
      'load_type': instance.loadType,
      'truck_type_required': instance.truckTypeRequired,
      'weight': instance.weight,
      'price': instance.price,
      'price_type': instance.priceType,
      'payment_terms': instance.paymentTerms,
      'loading_date': instance.loadingDate?.toIso8601String(),
      'notes': instance.notes,
      'contact_preferences_call': instance.contactPreferencesCall,
      'contact_preferences_chat': instance.contactPreferencesChat,
      'status': instance.status,
      'expires_at': instance.expiresAt.toIso8601String(),
      'view_count': instance.viewCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

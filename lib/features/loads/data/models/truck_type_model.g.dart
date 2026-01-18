// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'truck_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TruckTypeModelImpl _$$TruckTypeModelImplFromJson(Map<String, dynamic> json) =>
    _$TruckTypeModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TruckTypeModelImplToJson(
        _$TruckTypeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'displayOrder': instance.displayOrder,
    };

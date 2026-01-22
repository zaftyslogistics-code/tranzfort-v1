// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaterialTypeModelImpl _$$MaterialTypeModelImplFromJson(
  Map<String, dynamic> json,
) =>
    _$MaterialTypeModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MaterialTypeModelImplToJson(
  _$MaterialTypeModelImpl instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'displayOrder': instance.displayOrder,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedSearchModelImpl _$$SavedSearchModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SavedSearchModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      searchName: json['searchName'] as String?,
      fromLocation: json['fromLocation'] as String?,
      toLocation: json['toLocation'] as String?,
      truckType: json['truckType'] as String?,
      weightRangeMin: (json['weightRangeMin'] as num?)?.toDouble(),
      weightRangeMax: (json['weightRangeMax'] as num?)?.toDouble(),
      priceRangeMin: (json['priceRangeMin'] as num?)?.toDouble(),
      priceRangeMax: (json['priceRangeMax'] as num?)?.toDouble(),
      isAlertEnabled: json['isAlertEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SavedSearchModelImplToJson(
        _$SavedSearchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'searchName': instance.searchName,
      'fromLocation': instance.fromLocation,
      'toLocation': instance.toLocation,
      'truckType': instance.truckType,
      'weightRangeMin': instance.weightRangeMin,
      'weightRangeMax': instance.weightRangeMax,
      'priceRangeMin': instance.priceRangeMin,
      'priceRangeMax': instance.priceRangeMax,
      'isAlertEnabled': instance.isAlertEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

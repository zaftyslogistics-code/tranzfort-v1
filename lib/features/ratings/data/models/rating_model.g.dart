// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RatingModelImpl _$$RatingModelImplFromJson(Map<String, dynamic> json) =>
    _$RatingModelImpl(
      id: json['id'] as String,
      raterUserId: json['raterUserId'] as String,
      ratedUserId: json['ratedUserId'] as String,
      loadId: json['loadId'] as String?,
      ratingValue: (json['ratingValue'] as num).toInt(),
      feedbackText: json['feedbackText'] as String?,
      ratingType: json['ratingType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RatingModelImplToJson(_$RatingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'raterUserId': instance.raterUserId,
      'ratedUserId': instance.ratedUserId,
      'loadId': instance.loadId,
      'ratingValue': instance.ratingValue,
      'feedbackText': instance.feedbackText,
      'ratingType': instance.ratingType,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

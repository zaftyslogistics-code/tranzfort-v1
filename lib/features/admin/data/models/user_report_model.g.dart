// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserReportModelImpl _$$UserReportModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserReportModelImpl(
  id: json['id'] as String,
  reporterId: json['reporter_id'] as String,
  reportedEntityType: json['reported_entity_type'] as String,
  reportedEntityId: json['reported_entity_id'] as String,
  reason: json['reason'] as String,
  description: json['description'] as String?,
  status: json['status'] as String? ?? 'pending',
  adminNotes: json['admin_notes'] as String?,
  resolvedBy: json['resolved_by'] as String?,
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$UserReportModelImplToJson(
  _$UserReportModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reporter_id': instance.reporterId,
  'reported_entity_type': instance.reportedEntityType,
  'reported_entity_id': instance.reportedEntityId,
  'reason': instance.reason,
  'description': instance.description,
  'status': instance.status,
  'admin_notes': instance.adminNotes,
  'resolved_by': instance.resolvedBy,
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

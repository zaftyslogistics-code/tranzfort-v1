import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_report_model.freezed.dart';
part 'user_report_model.g.dart';

@freezed
class UserReportModel with _$UserReportModel {
  const factory UserReportModel({
    required String id,
    @JsonKey(name: 'reporter_id') required String reporterId,
    @JsonKey(name: 'reported_entity_type') required String reportedEntityType,
    @JsonKey(name: 'reported_entity_id') required String reportedEntityId,
    required String reason,
    String? description,
    @Default('pending') String status,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserReportModel;

  factory UserReportModel.fromJson(Map<String, dynamic> json) =>
      _$UserReportModelFromJson(json);
}

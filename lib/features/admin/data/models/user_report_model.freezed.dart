// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserReportModel _$UserReportModelFromJson(Map<String, dynamic> json) {
  return _UserReportModel.fromJson(json);
}

/// @nodoc
mixin _$UserReportModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'reporter_id')
  String get reporterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'reported_entity_type')
  String get reportedEntityType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reported_entity_id')
  String get reportedEntityId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'admin_notes')
  String? get adminNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserReportModelCopyWith<UserReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserReportModelCopyWith<$Res> {
  factory $UserReportModelCopyWith(
          UserReportModel value, $Res Function(UserReportModel) then) =
      _$UserReportModelCopyWithImpl<$Res, UserReportModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'reporter_id') String reporterId,
      @JsonKey(name: 'reported_entity_type') String reportedEntityType,
      @JsonKey(name: 'reported_entity_id') String reportedEntityId,
      String reason,
      String? description,
      String status,
      @JsonKey(name: 'admin_notes') String? adminNotes,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$UserReportModelCopyWithImpl<$Res, $Val extends UserReportModel>
    implements $UserReportModelCopyWith<$Res> {
  _$UserReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? reportedEntityType = null,
    Object? reportedEntityId = null,
    Object? reason = null,
    Object? description = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reporterId: null == reporterId
          ? _value.reporterId
          : reporterId // ignore: cast_nullable_to_non_nullable
              as String,
      reportedEntityType: null == reportedEntityType
          ? _value.reportedEntityType
          : reportedEntityType // ignore: cast_nullable_to_non_nullable
              as String,
      reportedEntityId: null == reportedEntityId
          ? _value.reportedEntityId
          : reportedEntityId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserReportModelImplCopyWith<$Res>
    implements $UserReportModelCopyWith<$Res> {
  factory _$$UserReportModelImplCopyWith(_$UserReportModelImpl value,
          $Res Function(_$UserReportModelImpl) then) =
      __$$UserReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'reporter_id') String reporterId,
      @JsonKey(name: 'reported_entity_type') String reportedEntityType,
      @JsonKey(name: 'reported_entity_id') String reportedEntityId,
      String reason,
      String? description,
      String status,
      @JsonKey(name: 'admin_notes') String? adminNotes,
      @JsonKey(name: 'resolved_by') String? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$UserReportModelImplCopyWithImpl<$Res>
    extends _$UserReportModelCopyWithImpl<$Res, _$UserReportModelImpl>
    implements _$$UserReportModelImplCopyWith<$Res> {
  __$$UserReportModelImplCopyWithImpl(
      _$UserReportModelImpl _value, $Res Function(_$UserReportModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterId = null,
    Object? reportedEntityType = null,
    Object? reportedEntityId = null,
    Object? reason = null,
    Object? description = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserReportModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reporterId: null == reporterId
          ? _value.reporterId
          : reporterId // ignore: cast_nullable_to_non_nullable
              as String,
      reportedEntityType: null == reportedEntityType
          ? _value.reportedEntityType
          : reportedEntityType // ignore: cast_nullable_to_non_nullable
              as String,
      reportedEntityId: null == reportedEntityId
          ? _value.reportedEntityId
          : reportedEntityId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserReportModelImpl implements _UserReportModel {
  const _$UserReportModelImpl(
      {required this.id,
      @JsonKey(name: 'reporter_id') required this.reporterId,
      @JsonKey(name: 'reported_entity_type') required this.reportedEntityType,
      @JsonKey(name: 'reported_entity_id') required this.reportedEntityId,
      required this.reason,
      this.description,
      this.status = 'pending',
      @JsonKey(name: 'admin_notes') this.adminNotes,
      @JsonKey(name: 'resolved_by') this.resolvedBy,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$UserReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserReportModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'reporter_id')
  final String reporterId;
  @override
  @JsonKey(name: 'reported_entity_type')
  final String reportedEntityType;
  @override
  @JsonKey(name: 'reported_entity_id')
  final String reportedEntityId;
  @override
  final String reason;
  @override
  final String? description;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserReportModel(id: $id, reporterId: $reporterId, reportedEntityType: $reportedEntityType, reportedEntityId: $reportedEntityId, reason: $reason, description: $description, status: $status, adminNotes: $adminNotes, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserReportModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reporterId, reporterId) ||
                other.reporterId == reporterId) &&
            (identical(other.reportedEntityType, reportedEntityType) ||
                other.reportedEntityType == reportedEntityType) &&
            (identical(other.reportedEntityId, reportedEntityId) ||
                other.reportedEntityId == reportedEntityId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reporterId,
      reportedEntityType,
      reportedEntityId,
      reason,
      description,
      status,
      adminNotes,
      resolvedBy,
      resolvedAt,
      createdAt,
      updatedAt);

  /// Create a copy of UserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserReportModelImplCopyWith<_$UserReportModelImpl> get copyWith =>
      __$$UserReportModelImplCopyWithImpl<_$UserReportModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserReportModelImplToJson(
      this,
    );
  }
}

abstract class _UserReportModel implements UserReportModel {
  const factory _UserReportModel(
          {required final String id,
          @JsonKey(name: 'reporter_id') required final String reporterId,
          @JsonKey(name: 'reported_entity_type')
          required final String reportedEntityType,
          @JsonKey(name: 'reported_entity_id')
          required final String reportedEntityId,
          required final String reason,
          final String? description,
          final String status,
          @JsonKey(name: 'admin_notes') final String? adminNotes,
          @JsonKey(name: 'resolved_by') final String? resolvedBy,
          @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$UserReportModelImpl;

  factory _UserReportModel.fromJson(Map<String, dynamic> json) =
      _$UserReportModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'reporter_id')
  String get reporterId;
  @override
  @JsonKey(name: 'reported_entity_type')
  String get reportedEntityType;
  @override
  @JsonKey(name: 'reported_entity_id')
  String get reportedEntityId;
  @override
  String get reason;
  @override
  String? get description;
  @override
  String get status;
  @override
  @JsonKey(name: 'admin_notes')
  String? get adminNotes;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserReportModelImplCopyWith<_$UserReportModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) {
  return _RatingModel.fromJson(json);
}

/// @nodoc
mixin _$RatingModel {
  String get id => throw _privateConstructorUsedError;
  String get raterUserId => throw _privateConstructorUsedError;
  String get ratedUserId => throw _privateConstructorUsedError;
  String? get loadId => throw _privateConstructorUsedError;
  int get ratingValue => throw _privateConstructorUsedError;
  String? get feedbackText => throw _privateConstructorUsedError;
  String get ratingType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RatingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatingModelCopyWith<RatingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingModelCopyWith<$Res> {
  factory $RatingModelCopyWith(
    RatingModel value,
    $Res Function(RatingModel) then,
  ) = _$RatingModelCopyWithImpl<$Res, RatingModel>;
  @useResult
  $Res call({
    String id,
    String raterUserId,
    String ratedUserId,
    String? loadId,
    int ratingValue,
    String? feedbackText,
    String ratingType,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$RatingModelCopyWithImpl<$Res, $Val extends RatingModel>
    implements $RatingModelCopyWith<$Res> {
  _$RatingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raterUserId = null,
    Object? ratedUserId = null,
    Object? loadId = freezed,
    Object? ratingValue = null,
    Object? feedbackText = freezed,
    Object? ratingType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        raterUserId: null == raterUserId
            ? _value.raterUserId
            : raterUserId // ignore: cast_nullable_to_non_nullable
                as String,
        ratedUserId: null == ratedUserId
            ? _value.ratedUserId
            : ratedUserId // ignore: cast_nullable_to_non_nullable
                as String,
        loadId: freezed == loadId
            ? _value.loadId
            : loadId // ignore: cast_nullable_to_non_nullable
                as String?,
        ratingValue: null == ratingValue
            ? _value.ratingValue
            : ratingValue // ignore: cast_nullable_to_non_nullable
                as int,
        feedbackText: freezed == feedbackText
            ? _value.feedbackText
            : feedbackText // ignore: cast_nullable_to_non_nullable
                as String?,
        ratingType: null == ratingType
            ? _value.ratingType
            : ratingType // ignore: cast_nullable_to_non_nullable
                as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
      ) as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RatingModelImplCopyWith<$Res>
    implements $RatingModelCopyWith<$Res> {
  factory _$$RatingModelImplCopyWith(
    _$RatingModelImpl value,
    $Res Function(_$RatingModelImpl) then,
  ) = __$$RatingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String raterUserId,
    String ratedUserId,
    String? loadId,
    int ratingValue,
    String? feedbackText,
    String ratingType,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$RatingModelImplCopyWithImpl<$Res>
    extends _$RatingModelCopyWithImpl<$Res, _$RatingModelImpl>
    implements _$$RatingModelImplCopyWith<$Res> {
  __$$RatingModelImplCopyWithImpl(
    _$RatingModelImpl _value,
    $Res Function(_$RatingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RatingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raterUserId = null,
    Object? ratedUserId = null,
    Object? loadId = freezed,
    Object? ratingValue = null,
    Object? feedbackText = freezed,
    Object? ratingType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$RatingModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        raterUserId: null == raterUserId
            ? _value.raterUserId
            : raterUserId // ignore: cast_nullable_to_non_nullable
                as String,
        ratedUserId: null == ratedUserId
            ? _value.ratedUserId
            : ratedUserId // ignore: cast_nullable_to_non_nullable
                as String,
        loadId: freezed == loadId
            ? _value.loadId
            : loadId // ignore: cast_nullable_to_non_nullable
                as String?,
        ratingValue: null == ratingValue
            ? _value.ratingValue
            : ratingValue // ignore: cast_nullable_to_non_nullable
                as int,
        feedbackText: freezed == feedbackText
            ? _value.feedbackText
            : feedbackText // ignore: cast_nullable_to_non_nullable
                as String?,
        ratingType: null == ratingType
            ? _value.ratingType
            : ratingType // ignore: cast_nullable_to_non_nullable
                as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingModelImpl implements _RatingModel {
  const _$RatingModelImpl({
    required this.id,
    required this.raterUserId,
    required this.ratedUserId,
    this.loadId,
    required this.ratingValue,
    this.feedbackText,
    required this.ratingType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$RatingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String raterUserId;
  @override
  final String ratedUserId;
  @override
  final String? loadId;
  @override
  final int ratingValue;
  @override
  final String? feedbackText;
  @override
  final String ratingType;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RatingModel(id: $id, raterUserId: $raterUserId, ratedUserId: $ratedUserId, loadId: $loadId, ratingValue: $ratingValue, feedbackText: $feedbackText, ratingType: $ratingType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.raterUserId, raterUserId) ||
                other.raterUserId == raterUserId) &&
            (identical(other.ratedUserId, ratedUserId) ||
                other.ratedUserId == ratedUserId) &&
            (identical(other.loadId, loadId) || other.loadId == loadId) &&
            (identical(other.ratingValue, ratingValue) ||
                other.ratingValue == ratingValue) &&
            (identical(other.feedbackText, feedbackText) ||
                other.feedbackText == feedbackText) &&
            (identical(other.ratingType, ratingType) ||
                other.ratingType == ratingType) &&
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
        raterUserId,
        ratedUserId,
        loadId,
        ratingValue,
        feedbackText,
        ratingType,
        createdAt,
        updatedAt,
      );

  /// Create a copy of RatingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingModelImplCopyWith<_$RatingModelImpl> get copyWith =>
      __$$RatingModelImplCopyWithImpl<_$RatingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingModelImplToJson(this);
  }
}

abstract class _RatingModel implements RatingModel {
  const factory _RatingModel({
    required final String id,
    required final String raterUserId,
    required final String ratedUserId,
    final String? loadId,
    required final int ratingValue,
    final String? feedbackText,
    required final String ratingType,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$RatingModelImpl;

  factory _RatingModel.fromJson(Map<String, dynamic> json) =
      _$RatingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get raterUserId;
  @override
  String get ratedUserId;
  @override
  String? get loadId;
  @override
  int get ratingValue;
  @override
  String? get feedbackText;
  @override
  String get ratingType;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of RatingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatingModelImplCopyWith<_$RatingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

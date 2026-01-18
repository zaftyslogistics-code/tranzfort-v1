// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_search_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SavedSearchModel _$SavedSearchModelFromJson(Map<String, dynamic> json) {
  return _SavedSearchModel.fromJson(json);
}

/// @nodoc
mixin _$SavedSearchModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get searchName => throw _privateConstructorUsedError;
  String? get fromLocation => throw _privateConstructorUsedError;
  String? get toLocation => throw _privateConstructorUsedError;
  String? get truckType => throw _privateConstructorUsedError;
  double? get weightRangeMin => throw _privateConstructorUsedError;
  double? get weightRangeMax => throw _privateConstructorUsedError;
  double? get priceRangeMin => throw _privateConstructorUsedError;
  double? get priceRangeMax => throw _privateConstructorUsedError;
  bool get isAlertEnabled => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SavedSearchModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedSearchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedSearchModelCopyWith<SavedSearchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedSearchModelCopyWith<$Res> {
  factory $SavedSearchModelCopyWith(
          SavedSearchModel value, $Res Function(SavedSearchModel) then) =
      _$SavedSearchModelCopyWithImpl<$Res, SavedSearchModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? searchName,
      String? fromLocation,
      String? toLocation,
      String? truckType,
      double? weightRangeMin,
      double? weightRangeMax,
      double? priceRangeMin,
      double? priceRangeMax,
      bool isAlertEnabled,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SavedSearchModelCopyWithImpl<$Res, $Val extends SavedSearchModel>
    implements $SavedSearchModelCopyWith<$Res> {
  _$SavedSearchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedSearchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? searchName = freezed,
    Object? fromLocation = freezed,
    Object? toLocation = freezed,
    Object? truckType = freezed,
    Object? weightRangeMin = freezed,
    Object? weightRangeMax = freezed,
    Object? priceRangeMin = freezed,
    Object? priceRangeMax = freezed,
    Object? isAlertEnabled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      searchName: freezed == searchName
          ? _value.searchName
          : searchName // ignore: cast_nullable_to_non_nullable
              as String?,
      fromLocation: freezed == fromLocation
          ? _value.fromLocation
          : fromLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      toLocation: freezed == toLocation
          ? _value.toLocation
          : toLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      truckType: freezed == truckType
          ? _value.truckType
          : truckType // ignore: cast_nullable_to_non_nullable
              as String?,
      weightRangeMin: freezed == weightRangeMin
          ? _value.weightRangeMin
          : weightRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      weightRangeMax: freezed == weightRangeMax
          ? _value.weightRangeMax
          : weightRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      priceRangeMin: freezed == priceRangeMin
          ? _value.priceRangeMin
          : priceRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      priceRangeMax: freezed == priceRangeMax
          ? _value.priceRangeMax
          : priceRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      isAlertEnabled: null == isAlertEnabled
          ? _value.isAlertEnabled
          : isAlertEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$SavedSearchModelImplCopyWith<$Res>
    implements $SavedSearchModelCopyWith<$Res> {
  factory _$$SavedSearchModelImplCopyWith(_$SavedSearchModelImpl value,
          $Res Function(_$SavedSearchModelImpl) then) =
      __$$SavedSearchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? searchName,
      String? fromLocation,
      String? toLocation,
      String? truckType,
      double? weightRangeMin,
      double? weightRangeMax,
      double? priceRangeMin,
      double? priceRangeMax,
      bool isAlertEnabled,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SavedSearchModelImplCopyWithImpl<$Res>
    extends _$SavedSearchModelCopyWithImpl<$Res, _$SavedSearchModelImpl>
    implements _$$SavedSearchModelImplCopyWith<$Res> {
  __$$SavedSearchModelImplCopyWithImpl(_$SavedSearchModelImpl _value,
      $Res Function(_$SavedSearchModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SavedSearchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? searchName = freezed,
    Object? fromLocation = freezed,
    Object? toLocation = freezed,
    Object? truckType = freezed,
    Object? weightRangeMin = freezed,
    Object? weightRangeMax = freezed,
    Object? priceRangeMin = freezed,
    Object? priceRangeMax = freezed,
    Object? isAlertEnabled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SavedSearchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      searchName: freezed == searchName
          ? _value.searchName
          : searchName // ignore: cast_nullable_to_non_nullable
              as String?,
      fromLocation: freezed == fromLocation
          ? _value.fromLocation
          : fromLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      toLocation: freezed == toLocation
          ? _value.toLocation
          : toLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      truckType: freezed == truckType
          ? _value.truckType
          : truckType // ignore: cast_nullable_to_non_nullable
              as String?,
      weightRangeMin: freezed == weightRangeMin
          ? _value.weightRangeMin
          : weightRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      weightRangeMax: freezed == weightRangeMax
          ? _value.weightRangeMax
          : weightRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      priceRangeMin: freezed == priceRangeMin
          ? _value.priceRangeMin
          : priceRangeMin // ignore: cast_nullable_to_non_nullable
              as double?,
      priceRangeMax: freezed == priceRangeMax
          ? _value.priceRangeMax
          : priceRangeMax // ignore: cast_nullable_to_non_nullable
              as double?,
      isAlertEnabled: null == isAlertEnabled
          ? _value.isAlertEnabled
          : isAlertEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$SavedSearchModelImpl implements _SavedSearchModel {
  const _$SavedSearchModelImpl(
      {required this.id,
      required this.userId,
      this.searchName,
      this.fromLocation,
      this.toLocation,
      this.truckType,
      this.weightRangeMin,
      this.weightRangeMax,
      this.priceRangeMin,
      this.priceRangeMax,
      this.isAlertEnabled = true,
      required this.createdAt,
      required this.updatedAt});

  factory _$SavedSearchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedSearchModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? searchName;
  @override
  final String? fromLocation;
  @override
  final String? toLocation;
  @override
  final String? truckType;
  @override
  final double? weightRangeMin;
  @override
  final double? weightRangeMax;
  @override
  final double? priceRangeMin;
  @override
  final double? priceRangeMax;
  @override
  @JsonKey()
  final bool isAlertEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SavedSearchModel(id: $id, userId: $userId, searchName: $searchName, fromLocation: $fromLocation, toLocation: $toLocation, truckType: $truckType, weightRangeMin: $weightRangeMin, weightRangeMax: $weightRangeMax, priceRangeMin: $priceRangeMin, priceRangeMax: $priceRangeMax, isAlertEnabled: $isAlertEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedSearchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.searchName, searchName) ||
                other.searchName == searchName) &&
            (identical(other.fromLocation, fromLocation) ||
                other.fromLocation == fromLocation) &&
            (identical(other.toLocation, toLocation) ||
                other.toLocation == toLocation) &&
            (identical(other.truckType, truckType) ||
                other.truckType == truckType) &&
            (identical(other.weightRangeMin, weightRangeMin) ||
                other.weightRangeMin == weightRangeMin) &&
            (identical(other.weightRangeMax, weightRangeMax) ||
                other.weightRangeMax == weightRangeMax) &&
            (identical(other.priceRangeMin, priceRangeMin) ||
                other.priceRangeMin == priceRangeMin) &&
            (identical(other.priceRangeMax, priceRangeMax) ||
                other.priceRangeMax == priceRangeMax) &&
            (identical(other.isAlertEnabled, isAlertEnabled) ||
                other.isAlertEnabled == isAlertEnabled) &&
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
      userId,
      searchName,
      fromLocation,
      toLocation,
      truckType,
      weightRangeMin,
      weightRangeMax,
      priceRangeMin,
      priceRangeMax,
      isAlertEnabled,
      createdAt,
      updatedAt);

  /// Create a copy of SavedSearchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedSearchModelImplCopyWith<_$SavedSearchModelImpl> get copyWith =>
      __$$SavedSearchModelImplCopyWithImpl<_$SavedSearchModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedSearchModelImplToJson(
      this,
    );
  }
}

abstract class _SavedSearchModel implements SavedSearchModel {
  const factory _SavedSearchModel(
      {required final String id,
      required final String userId,
      final String? searchName,
      final String? fromLocation,
      final String? toLocation,
      final String? truckType,
      final double? weightRangeMin,
      final double? weightRangeMax,
      final double? priceRangeMin,
      final double? priceRangeMax,
      final bool isAlertEnabled,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SavedSearchModelImpl;

  factory _SavedSearchModel.fromJson(Map<String, dynamic> json) =
      _$SavedSearchModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get searchName;
  @override
  String? get fromLocation;
  @override
  String? get toLocation;
  @override
  String? get truckType;
  @override
  double? get weightRangeMin;
  @override
  double? get weightRangeMax;
  @override
  double? get priceRangeMin;
  @override
  double? get priceRangeMax;
  @override
  bool get isAlertEnabled;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SavedSearchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedSearchModelImplCopyWith<_$SavedSearchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

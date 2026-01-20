// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'truck_type_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TruckTypeModel _$TruckTypeModelFromJson(Map<String, dynamic> json) {
  return _TruckTypeModel.fromJson(json);
}

/// @nodoc
mixin _$TruckTypeModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;

  /// Serializes this TruckTypeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TruckTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TruckTypeModelCopyWith<TruckTypeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TruckTypeModelCopyWith<$Res> {
  factory $TruckTypeModelCopyWith(
    TruckTypeModel value,
    $Res Function(TruckTypeModel) then,
  ) = _$TruckTypeModelCopyWithImpl<$Res, TruckTypeModel>;
  @useResult
  $Res call({int id, String name, String? category, int displayOrder});
}

/// @nodoc
class _$TruckTypeModelCopyWithImpl<$Res, $Val extends TruckTypeModel>
    implements $TruckTypeModelCopyWith<$Res> {
  _$TruckTypeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TruckTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TruckTypeModelImplCopyWith<$Res>
    implements $TruckTypeModelCopyWith<$Res> {
  factory _$$TruckTypeModelImplCopyWith(
    _$TruckTypeModelImpl value,
    $Res Function(_$TruckTypeModelImpl) then,
  ) = __$$TruckTypeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String? category, int displayOrder});
}

/// @nodoc
class __$$TruckTypeModelImplCopyWithImpl<$Res>
    extends _$TruckTypeModelCopyWithImpl<$Res, _$TruckTypeModelImpl>
    implements _$$TruckTypeModelImplCopyWith<$Res> {
  __$$TruckTypeModelImplCopyWithImpl(
    _$TruckTypeModelImpl _value,
    $Res Function(_$TruckTypeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TruckTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _$TruckTypeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TruckTypeModelImpl implements _TruckTypeModel {
  const _$TruckTypeModelImpl({
    required this.id,
    required this.name,
    this.category,
    this.displayOrder = 0,
  });

  factory _$TruckTypeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TruckTypeModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? category;
  @override
  @JsonKey()
  final int displayOrder;

  @override
  String toString() {
    return 'TruckTypeModel(id: $id, name: $name, category: $category, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TruckTypeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, category, displayOrder);

  /// Create a copy of TruckTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TruckTypeModelImplCopyWith<_$TruckTypeModelImpl> get copyWith =>
      __$$TruckTypeModelImplCopyWithImpl<_$TruckTypeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TruckTypeModelImplToJson(this);
  }
}

abstract class _TruckTypeModel implements TruckTypeModel {
  const factory _TruckTypeModel({
    required final int id,
    required final String name,
    final String? category,
    final int displayOrder,
  }) = _$TruckTypeModelImpl;

  factory _TruckTypeModel.fromJson(Map<String, dynamic> json) =
      _$TruckTypeModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get category;
  @override
  int get displayOrder;

  /// Create a copy of TruckTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TruckTypeModelImplCopyWith<_$TruckTypeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_number')
  String get mobileNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'country_code')
  String get countryCode => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_supplier_enabled')
  bool get isSupplierEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_trucker_enabled')
  bool get isTruckerEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'supplier_verification_status')
  String get supplierVerificationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'trucker_verification_status')
  String get truckerVerificationStatus => throw _privateConstructorUsedError;
  Map<String, dynamic> get preferences => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_login_at')
  DateTime get lastLoginAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'mobile_number') String mobileNumber,
    @JsonKey(name: 'country_code') String countryCode,
    String? name,
    @JsonKey(name: 'is_supplier_enabled') bool isSupplierEnabled,
    @JsonKey(name: 'is_trucker_enabled') bool isTruckerEnabled,
    @JsonKey(name: 'supplier_verification_status')
    String supplierVerificationStatus,
    @JsonKey(name: 'trucker_verification_status')
    String truckerVerificationStatus,
    Map<String, dynamic> preferences,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'last_login_at') DateTime lastLoginAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mobileNumber = null,
    Object? countryCode = null,
    Object? name = freezed,
    Object? isSupplierEnabled = null,
    Object? isTruckerEnabled = null,
    Object? supplierVerificationStatus = null,
    Object? truckerVerificationStatus = null,
    Object? preferences = null,
    Object? createdAt = null,
    Object? lastLoginAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            mobileNumber: null == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSupplierEnabled: null == isSupplierEnabled
                ? _value.isSupplierEnabled
                : isSupplierEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            isTruckerEnabled: null == isTruckerEnabled
                ? _value.isTruckerEnabled
                : isTruckerEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            supplierVerificationStatus: null == supplierVerificationStatus
                ? _value.supplierVerificationStatus
                : supplierVerificationStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            truckerVerificationStatus: null == truckerVerificationStatus
                ? _value.truckerVerificationStatus
                : truckerVerificationStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            preferences: null == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLoginAt: null == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'mobile_number') String mobileNumber,
    @JsonKey(name: 'country_code') String countryCode,
    String? name,
    @JsonKey(name: 'is_supplier_enabled') bool isSupplierEnabled,
    @JsonKey(name: 'is_trucker_enabled') bool isTruckerEnabled,
    @JsonKey(name: 'supplier_verification_status')
    String supplierVerificationStatus,
    @JsonKey(name: 'trucker_verification_status')
    String truckerVerificationStatus,
    Map<String, dynamic> preferences,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'last_login_at') DateTime lastLoginAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mobileNumber = null,
    Object? countryCode = null,
    Object? name = freezed,
    Object? isSupplierEnabled = null,
    Object? isTruckerEnabled = null,
    Object? supplierVerificationStatus = null,
    Object? truckerVerificationStatus = null,
    Object? preferences = null,
    Object? createdAt = null,
    Object? lastLoginAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        mobileNumber: null == mobileNumber
            ? _value.mobileNumber
            : mobileNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSupplierEnabled: null == isSupplierEnabled
            ? _value.isSupplierEnabled
            : isSupplierEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        isTruckerEnabled: null == isTruckerEnabled
            ? _value.isTruckerEnabled
            : isTruckerEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        supplierVerificationStatus: null == supplierVerificationStatus
            ? _value.supplierVerificationStatus
            : supplierVerificationStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        truckerVerificationStatus: null == truckerVerificationStatus
            ? _value.truckerVerificationStatus
            : truckerVerificationStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        preferences: null == preferences
            ? _value._preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLoginAt: null == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
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
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    @JsonKey(name: 'mobile_number') required this.mobileNumber,
    @JsonKey(name: 'country_code') this.countryCode = '+91',
    this.name,
    @JsonKey(name: 'is_supplier_enabled') this.isSupplierEnabled = false,
    @JsonKey(name: 'is_trucker_enabled') this.isTruckerEnabled = false,
    @JsonKey(name: 'supplier_verification_status')
    this.supplierVerificationStatus = 'unverified',
    @JsonKey(name: 'trucker_verification_status')
    this.truckerVerificationStatus = 'unverified',
    final Map<String, dynamic> preferences = const {},
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'last_login_at') required this.lastLoginAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _preferences = preferences;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'mobile_number')
  final String mobileNumber;
  @override
  @JsonKey(name: 'country_code')
  final String countryCode;
  @override
  final String? name;
  @override
  @JsonKey(name: 'is_supplier_enabled')
  final bool isSupplierEnabled;
  @override
  @JsonKey(name: 'is_trucker_enabled')
  final bool isTruckerEnabled;
  @override
  @JsonKey(name: 'supplier_verification_status')
  final String supplierVerificationStatus;
  @override
  @JsonKey(name: 'trucker_verification_status')
  final String truckerVerificationStatus;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'last_login_at')
  final DateTime lastLoginAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserModel(id: $id, mobileNumber: $mobileNumber, countryCode: $countryCode, name: $name, isSupplierEnabled: $isSupplierEnabled, isTruckerEnabled: $isTruckerEnabled, supplierVerificationStatus: $supplierVerificationStatus, truckerVerificationStatus: $truckerVerificationStatus, preferences: $preferences, createdAt: $createdAt, lastLoginAt: $lastLoginAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isSupplierEnabled, isSupplierEnabled) ||
                other.isSupplierEnabled == isSupplierEnabled) &&
            (identical(other.isTruckerEnabled, isTruckerEnabled) ||
                other.isTruckerEnabled == isTruckerEnabled) &&
            (identical(
                  other.supplierVerificationStatus,
                  supplierVerificationStatus,
                ) ||
                other.supplierVerificationStatus ==
                    supplierVerificationStatus) &&
            (identical(
                  other.truckerVerificationStatus,
                  truckerVerificationStatus,
                ) ||
                other.truckerVerificationStatus == truckerVerificationStatus) &&
            const DeepCollectionEquality().equals(
              other._preferences,
              _preferences,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    mobileNumber,
    countryCode,
    name,
    isSupplierEnabled,
    isTruckerEnabled,
    supplierVerificationStatus,
    truckerVerificationStatus,
    const DeepCollectionEquality().hash(_preferences),
    createdAt,
    lastLoginAt,
    updatedAt,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String id,
    @JsonKey(name: 'mobile_number') required final String mobileNumber,
    @JsonKey(name: 'country_code') final String countryCode,
    final String? name,
    @JsonKey(name: 'is_supplier_enabled') final bool isSupplierEnabled,
    @JsonKey(name: 'is_trucker_enabled') final bool isTruckerEnabled,
    @JsonKey(name: 'supplier_verification_status')
    final String supplierVerificationStatus,
    @JsonKey(name: 'trucker_verification_status')
    final String truckerVerificationStatus,
    final Map<String, dynamic> preferences,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'last_login_at') required final DateTime lastLoginAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'mobile_number')
  String get mobileNumber;
  @override
  @JsonKey(name: 'country_code')
  String get countryCode;
  @override
  String? get name;
  @override
  @JsonKey(name: 'is_supplier_enabled')
  bool get isSupplierEnabled;
  @override
  @JsonKey(name: 'is_trucker_enabled')
  bool get isTruckerEnabled;
  @override
  @JsonKey(name: 'supplier_verification_status')
  String get supplierVerificationStatus;
  @override
  @JsonKey(name: 'trucker_verification_status')
  String get truckerVerificationStatus;
  @override
  Map<String, dynamic> get preferences;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'last_login_at')
  DateTime get lastLoginAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'load_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoadModel _$LoadModelFromJson(Map<String, dynamic> json) {
  return _LoadModel.fromJson(json);
}

/// @nodoc
mixin _$LoadModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'supplier_id')
  String get supplierId => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_location')
  String get fromLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_city')
  String get fromCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_state')
  String? get fromState => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_location')
  String get toLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_city')
  String get toCity => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_state')
  String? get toState => throw _privateConstructorUsedError;
  @JsonKey(name: 'load_type')
  String get loadType => throw _privateConstructorUsedError;
  @JsonKey(name: 'truck_type_required')
  String get truckTypeRequired => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_type')
  String get priceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_terms')
  String? get paymentTerms => throw _privateConstructorUsedError;
  @JsonKey(name: 'loading_date')
  DateTime? get loadingDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_preferences_call')
  bool get contactPreferencesCall => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_preferences_chat')
  bool get contactPreferencesChat => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LoadModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoadModelCopyWith<LoadModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoadModelCopyWith<$Res> {
  factory $LoadModelCopyWith(LoadModel value, $Res Function(LoadModel) then) =
      _$LoadModelCopyWithImpl<$Res, LoadModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'supplier_id') String supplierId,
    @JsonKey(name: 'from_location') String fromLocation,
    @JsonKey(name: 'from_city') String fromCity,
    @JsonKey(name: 'from_state') String? fromState,
    @JsonKey(name: 'to_location') String toLocation,
    @JsonKey(name: 'to_city') String toCity,
    @JsonKey(name: 'to_state') String? toState,
    @JsonKey(name: 'load_type') String loadType,
    @JsonKey(name: 'truck_type_required') String truckTypeRequired,
    double? weight,
    double? price,
    @JsonKey(name: 'price_type') String priceType,
    @JsonKey(name: 'payment_terms') String? paymentTerms,
    @JsonKey(name: 'loading_date') DateTime? loadingDate,
    String? notes,
    @JsonKey(name: 'contact_preferences_call') bool contactPreferencesCall,
    @JsonKey(name: 'contact_preferences_chat') bool contactPreferencesChat,
    String status,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
    @JsonKey(name: 'view_count') int viewCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$LoadModelCopyWithImpl<$Res, $Val extends LoadModel>
    implements $LoadModelCopyWith<$Res> {
  _$LoadModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? fromLocation = null,
    Object? fromCity = null,
    Object? fromState = freezed,
    Object? toLocation = null,
    Object? toCity = null,
    Object? toState = freezed,
    Object? loadType = null,
    Object? truckTypeRequired = null,
    Object? weight = freezed,
    Object? price = freezed,
    Object? priceType = null,
    Object? paymentTerms = freezed,
    Object? loadingDate = freezed,
    Object? notes = freezed,
    Object? contactPreferencesCall = null,
    Object? contactPreferencesChat = null,
    Object? status = null,
    Object? expiresAt = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        supplierId: null == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                as String,
        fromLocation: null == fromLocation
            ? _value.fromLocation
            : fromLocation // ignore: cast_nullable_to_non_nullable
                as String,
        fromCity: null == fromCity
            ? _value.fromCity
            : fromCity // ignore: cast_nullable_to_non_nullable
                as String,
        fromState: freezed == fromState
            ? _value.fromState
            : fromState // ignore: cast_nullable_to_non_nullable
                as String?,
        toLocation: null == toLocation
            ? _value.toLocation
            : toLocation // ignore: cast_nullable_to_non_nullable
                as String,
        toCity: null == toCity
            ? _value.toCity
            : toCity // ignore: cast_nullable_to_non_nullable
                as String,
        toState: freezed == toState
            ? _value.toState
            : toState // ignore: cast_nullable_to_non_nullable
                as String?,
        loadType: null == loadType
            ? _value.loadType
            : loadType // ignore: cast_nullable_to_non_nullable
                as String,
        truckTypeRequired: null == truckTypeRequired
            ? _value.truckTypeRequired
            : truckTypeRequired // ignore: cast_nullable_to_non_nullable
                as String,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                as double?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                as double?,
        priceType: null == priceType
            ? _value.priceType
            : priceType // ignore: cast_nullable_to_non_nullable
                as String,
        paymentTerms: freezed == paymentTerms
            ? _value.paymentTerms
            : paymentTerms // ignore: cast_nullable_to_non_nullable
                as String?,
        loadingDate: freezed == loadingDate
            ? _value.loadingDate
            : loadingDate // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                as String?,
        contactPreferencesCall: null == contactPreferencesCall
            ? _value.contactPreferencesCall
            : contactPreferencesCall // ignore: cast_nullable_to_non_nullable
                as bool,
        contactPreferencesChat: null == contactPreferencesChat
            ? _value.contactPreferencesChat
            : contactPreferencesChat // ignore: cast_nullable_to_non_nullable
                as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                as int,
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
abstract class _$$LoadModelImplCopyWith<$Res>
    implements $LoadModelCopyWith<$Res> {
  factory _$$LoadModelImplCopyWith(
    _$LoadModelImpl value,
    $Res Function(_$LoadModelImpl) then,
  ) = __$$LoadModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'supplier_id') String supplierId,
    @JsonKey(name: 'from_location') String fromLocation,
    @JsonKey(name: 'from_city') String fromCity,
    @JsonKey(name: 'from_state') String? fromState,
    @JsonKey(name: 'to_location') String toLocation,
    @JsonKey(name: 'to_city') String toCity,
    @JsonKey(name: 'to_state') String? toState,
    @JsonKey(name: 'load_type') String loadType,
    @JsonKey(name: 'truck_type_required') String truckTypeRequired,
    double? weight,
    double? price,
    @JsonKey(name: 'price_type') String priceType,
    @JsonKey(name: 'payment_terms') String? paymentTerms,
    @JsonKey(name: 'loading_date') DateTime? loadingDate,
    String? notes,
    @JsonKey(name: 'contact_preferences_call') bool contactPreferencesCall,
    @JsonKey(name: 'contact_preferences_chat') bool contactPreferencesChat,
    String status,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
    @JsonKey(name: 'view_count') int viewCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$LoadModelImplCopyWithImpl<$Res>
    extends _$LoadModelCopyWithImpl<$Res, _$LoadModelImpl>
    implements _$$LoadModelImplCopyWith<$Res> {
  __$$LoadModelImplCopyWithImpl(
    _$LoadModelImpl _value,
    $Res Function(_$LoadModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? fromLocation = null,
    Object? fromCity = null,
    Object? fromState = freezed,
    Object? toLocation = null,
    Object? toCity = null,
    Object? toState = freezed,
    Object? loadType = null,
    Object? truckTypeRequired = null,
    Object? weight = freezed,
    Object? price = freezed,
    Object? priceType = null,
    Object? paymentTerms = freezed,
    Object? loadingDate = freezed,
    Object? notes = freezed,
    Object? contactPreferencesCall = null,
    Object? contactPreferencesChat = null,
    Object? status = null,
    Object? expiresAt = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$LoadModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        supplierId: null == supplierId
            ? _value.supplierId
            : supplierId // ignore: cast_nullable_to_non_nullable
                as String,
        fromLocation: null == fromLocation
            ? _value.fromLocation
            : fromLocation // ignore: cast_nullable_to_non_nullable
                as String,
        fromCity: null == fromCity
            ? _value.fromCity
            : fromCity // ignore: cast_nullable_to_non_nullable
                as String,
        fromState: freezed == fromState
            ? _value.fromState
            : fromState // ignore: cast_nullable_to_non_nullable
                as String?,
        toLocation: null == toLocation
            ? _value.toLocation
            : toLocation // ignore: cast_nullable_to_non_nullable
                as String,
        toCity: null == toCity
            ? _value.toCity
            : toCity // ignore: cast_nullable_to_non_nullable
                as String,
        toState: freezed == toState
            ? _value.toState
            : toState // ignore: cast_nullable_to_non_nullable
                as String?,
        loadType: null == loadType
            ? _value.loadType
            : loadType // ignore: cast_nullable_to_non_nullable
                as String,
        truckTypeRequired: null == truckTypeRequired
            ? _value.truckTypeRequired
            : truckTypeRequired // ignore: cast_nullable_to_non_nullable
                as String,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                as double?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                as double?,
        priceType: null == priceType
            ? _value.priceType
            : priceType // ignore: cast_nullable_to_non_nullable
                as String,
        paymentTerms: freezed == paymentTerms
            ? _value.paymentTerms
            : paymentTerms // ignore: cast_nullable_to_non_nullable
                as String?,
        loadingDate: freezed == loadingDate
            ? _value.loadingDate
            : loadingDate // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                as String?,
        contactPreferencesCall: null == contactPreferencesCall
            ? _value.contactPreferencesCall
            : contactPreferencesCall // ignore: cast_nullable_to_non_nullable
                as bool,
        contactPreferencesChat: null == contactPreferencesChat
            ? _value.contactPreferencesChat
            : contactPreferencesChat // ignore: cast_nullable_to_non_nullable
                as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                as int,
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
class _$LoadModelImpl implements _LoadModel {
  const _$LoadModelImpl({
    required this.id,
    @JsonKey(name: 'supplier_id') required this.supplierId,
    @JsonKey(name: 'from_location') required this.fromLocation,
    @JsonKey(name: 'from_city') required this.fromCity,
    @JsonKey(name: 'from_state') this.fromState,
    @JsonKey(name: 'to_location') required this.toLocation,
    @JsonKey(name: 'to_city') required this.toCity,
    @JsonKey(name: 'to_state') this.toState,
    @JsonKey(name: 'load_type') required this.loadType,
    @JsonKey(name: 'truck_type_required') required this.truckTypeRequired,
    this.weight,
    this.price,
    @JsonKey(name: 'price_type') this.priceType = 'negotiable',
    @JsonKey(name: 'payment_terms') this.paymentTerms,
    @JsonKey(name: 'loading_date') this.loadingDate,
    this.notes,
    @JsonKey(name: 'contact_preferences_call')
    this.contactPreferencesCall = true,
    @JsonKey(name: 'contact_preferences_chat')
    this.contactPreferencesChat = true,
    this.status = 'active',
    @JsonKey(name: 'expires_at') required this.expiresAt,
    @JsonKey(name: 'view_count') this.viewCount = 0,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$LoadModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoadModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'supplier_id')
  final String supplierId;
  @override
  @JsonKey(name: 'from_location')
  final String fromLocation;
  @override
  @JsonKey(name: 'from_city')
  final String fromCity;
  @override
  @JsonKey(name: 'from_state')
  final String? fromState;
  @override
  @JsonKey(name: 'to_location')
  final String toLocation;
  @override
  @JsonKey(name: 'to_city')
  final String toCity;
  @override
  @JsonKey(name: 'to_state')
  final String? toState;
  @override
  @JsonKey(name: 'load_type')
  final String loadType;
  @override
  @JsonKey(name: 'truck_type_required')
  final String truckTypeRequired;
  @override
  final double? weight;
  @override
  final double? price;
  @override
  @JsonKey(name: 'price_type')
  final String priceType;
  @override
  @JsonKey(name: 'payment_terms')
  final String? paymentTerms;
  @override
  @JsonKey(name: 'loading_date')
  final DateTime? loadingDate;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'contact_preferences_call')
  final bool contactPreferencesCall;
  @override
  @JsonKey(name: 'contact_preferences_chat')
  final bool contactPreferencesChat;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @override
  @JsonKey(name: 'view_count')
  final int viewCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'LoadModel(id: $id, supplierId: $supplierId, fromLocation: $fromLocation, fromCity: $fromCity, fromState: $fromState, toLocation: $toLocation, toCity: $toCity, toState: $toState, loadType: $loadType, truckTypeRequired: $truckTypeRequired, weight: $weight, price: $price, priceType: $priceType, paymentTerms: $paymentTerms, loadingDate: $loadingDate, notes: $notes, contactPreferencesCall: $contactPreferencesCall, contactPreferencesChat: $contactPreferencesChat, status: $status, expiresAt: $expiresAt, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.fromLocation, fromLocation) ||
                other.fromLocation == fromLocation) &&
            (identical(other.fromCity, fromCity) ||
                other.fromCity == fromCity) &&
            (identical(other.fromState, fromState) ||
                other.fromState == fromState) &&
            (identical(other.toLocation, toLocation) ||
                other.toLocation == toLocation) &&
            (identical(other.toCity, toCity) || other.toCity == toCity) &&
            (identical(other.toState, toState) || other.toState == toState) &&
            (identical(other.loadType, loadType) ||
                other.loadType == loadType) &&
            (identical(other.truckTypeRequired, truckTypeRequired) ||
                other.truckTypeRequired == truckTypeRequired) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceType, priceType) ||
                other.priceType == priceType) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            (identical(other.loadingDate, loadingDate) ||
                other.loadingDate == loadingDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.contactPreferencesCall, contactPreferencesCall) ||
                other.contactPreferencesCall == contactPreferencesCall) &&
            (identical(other.contactPreferencesChat, contactPreferencesChat) ||
                other.contactPreferencesChat == contactPreferencesChat) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        supplierId,
        fromLocation,
        fromCity,
        fromState,
        toLocation,
        toCity,
        toState,
        loadType,
        truckTypeRequired,
        weight,
        price,
        priceType,
        paymentTerms,
        loadingDate,
        notes,
        contactPreferencesCall,
        contactPreferencesChat,
        status,
        expiresAt,
        viewCount,
        createdAt,
        updatedAt,
      ]);

  /// Create a copy of LoadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadModelImplCopyWith<_$LoadModelImpl> get copyWith =>
      __$$LoadModelImplCopyWithImpl<_$LoadModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoadModelImplToJson(this);
  }
}

abstract class _LoadModel implements LoadModel {
  const factory _LoadModel({
    required final String id,
    @JsonKey(name: 'supplier_id') required final String supplierId,
    @JsonKey(name: 'from_location') required final String fromLocation,
    @JsonKey(name: 'from_city') required final String fromCity,
    @JsonKey(name: 'from_state') final String? fromState,
    @JsonKey(name: 'to_location') required final String toLocation,
    @JsonKey(name: 'to_city') required final String toCity,
    @JsonKey(name: 'to_state') final String? toState,
    @JsonKey(name: 'load_type') required final String loadType,
    @JsonKey(name: 'truck_type_required')
    required final String truckTypeRequired,
    final double? weight,
    final double? price,
    @JsonKey(name: 'price_type') final String priceType,
    @JsonKey(name: 'payment_terms') final String? paymentTerms,
    @JsonKey(name: 'loading_date') final DateTime? loadingDate,
    final String? notes,
    @JsonKey(name: 'contact_preferences_call')
    final bool contactPreferencesCall,
    @JsonKey(name: 'contact_preferences_chat')
    final bool contactPreferencesChat,
    final String status,
    @JsonKey(name: 'expires_at') required final DateTime expiresAt,
    @JsonKey(name: 'view_count') final int viewCount,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$LoadModelImpl;

  factory _LoadModel.fromJson(Map<String, dynamic> json) =
      _$LoadModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'supplier_id')
  String get supplierId;
  @override
  @JsonKey(name: 'from_location')
  String get fromLocation;
  @override
  @JsonKey(name: 'from_city')
  String get fromCity;
  @override
  @JsonKey(name: 'from_state')
  String? get fromState;
  @override
  @JsonKey(name: 'to_location')
  String get toLocation;
  @override
  @JsonKey(name: 'to_city')
  String get toCity;
  @override
  @JsonKey(name: 'to_state')
  String? get toState;
  @override
  @JsonKey(name: 'load_type')
  String get loadType;
  @override
  @JsonKey(name: 'truck_type_required')
  String get truckTypeRequired;
  @override
  double? get weight;
  @override
  double? get price;
  @override
  @JsonKey(name: 'price_type')
  String get priceType;
  @override
  @JsonKey(name: 'payment_terms')
  String? get paymentTerms;
  @override
  @JsonKey(name: 'loading_date')
  DateTime? get loadingDate;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'contact_preferences_call')
  bool get contactPreferencesCall;
  @override
  @JsonKey(name: 'contact_preferences_chat')
  bool get contactPreferencesChat;
  @override
  String get status;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;
  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of LoadModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadModelImplCopyWith<_$LoadModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @JsonKey(name: 'mobile_number') required String mobileNumber,
    @JsonKey(name: 'country_code') @Default('+91') String countryCode,
    String? name,
    @JsonKey(name: 'is_supplier_enabled') @Default(false) bool isSupplierEnabled,
    @JsonKey(name: 'is_trucker_enabled') @Default(false) bool isTruckerEnabled,
    @JsonKey(name: 'supplier_verification_status') @Default('unverified') String supplierVerificationStatus,
    @JsonKey(name: 'trucker_verification_status') @Default('unverified') String truckerVerificationStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_login_at') required DateTime lastLoginAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

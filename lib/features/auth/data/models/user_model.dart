import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String mobileNumber,
    @Default('+91') String countryCode,
    String? name,
    @Default(false) bool isSupplierEnabled,
    @Default(false) bool isTruckerEnabled,
    @Default('unverified') String supplierVerificationStatus,
    @Default('unverified') String truckerVerificationStatus,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

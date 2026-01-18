import 'package:freezed_annotation/freezed_annotation.dart';

part 'load_model.freezed.dart';
part 'load_model.g.dart';

@freezed
class LoadModel with _$LoadModel {
  const factory LoadModel({
    required String id,
    required String supplierId,
    required String fromLocation,
    required String fromCity,
    String? fromState,
    required String toLocation,
    required String toCity,
    String? toState,
    required String loadType,
    required String truckTypeRequired,
    double? weight,
    double? price,
    @Default('negotiable') String priceType,
    String? paymentTerms,
    DateTime? loadingDate,
    String? notes,
    @Default(true) bool contactPreferencesCall,
    @Default(true) bool contactPreferencesChat,
    @Default('active') String status,
    required DateTime expiresAt,
    @Default(0) int viewCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LoadModel;

  factory LoadModel.fromJson(Map<String, dynamic> json) =>
      _$LoadModelFromJson(json);
}

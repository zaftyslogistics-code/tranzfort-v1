import 'package:freezed_annotation/freezed_annotation.dart';

part 'load_model.freezed.dart';
part 'load_model.g.dart';

@freezed
class LoadModel with _$LoadModel {
  const factory LoadModel({
    required String id,
    @JsonKey(name: 'supplier_id') required String supplierId,
    @JsonKey(name: 'from_location') required String fromLocation,
    @JsonKey(name: 'from_city') required String fromCity,
    @JsonKey(name: 'from_state') String? fromState,
    @JsonKey(name: 'to_location') required String toLocation,
    @JsonKey(name: 'to_city') required String toCity,
    @JsonKey(name: 'to_state') String? toState,
    @JsonKey(name: 'load_type') required String loadType,
    @JsonKey(name: 'truck_type_required') required String truckTypeRequired,
    double? weight,
    double? price,
    @JsonKey(name: 'price_type') @Default('negotiable') String priceType,
    @JsonKey(name: 'payment_terms') String? paymentTerms,
    @JsonKey(name: 'loading_date') DateTime? loadingDate,
    String? notes,
    @JsonKey(name: 'contact_preferences_call')
    @Default(true)
    bool contactPreferencesCall,
    @JsonKey(name: 'contact_preferences_chat')
    @Default(true)
    bool contactPreferencesChat,
    @Default('active') String status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _LoadModel;

  factory LoadModel.fromJson(Map<String, dynamic> json) =>
      _$LoadModelFromJson(json);
}

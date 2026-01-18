import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_search_model.freezed.dart';
part 'saved_search_model.g.dart';

@freezed
class SavedSearchModel with _$SavedSearchModel {
  const factory SavedSearchModel({
    required String id,
    required String userId,
    String? searchName,
    String? fromLocation,
    String? toLocation,
    String? truckType,
    double? weightRangeMin,
    double? weightRangeMax,
    double? priceRangeMin,
    double? priceRangeMax,
    @Default(true) bool isAlertEnabled,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SavedSearchModel;

  factory SavedSearchModel.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchModelFromJson(json);
}

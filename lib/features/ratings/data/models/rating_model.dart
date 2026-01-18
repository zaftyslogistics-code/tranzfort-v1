import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_model.freezed.dart';
part 'rating_model.g.dart';

@freezed
class RatingModel with _$RatingModel {
  const factory RatingModel({
    required String id,
    required String raterUserId,
    required String ratedUserId,
    String? loadId,
    required int ratingValue,
    String? feedbackText,
    required String ratingType,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RatingModel;

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}

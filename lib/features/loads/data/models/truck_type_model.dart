import 'package:freezed_annotation/freezed_annotation.dart';

part 'truck_type_model.freezed.dart';
part 'truck_type_model.g.dart';

@freezed
class TruckTypeModel with _$TruckTypeModel {
  const factory TruckTypeModel({
    required int id,
    required String name,
    String? category,
    @Default(0) int displayOrder,
  }) = _TruckTypeModel;

  factory TruckTypeModel.fromJson(Map<String, dynamic> json) =>
      _$TruckTypeModelFromJson(json);
}

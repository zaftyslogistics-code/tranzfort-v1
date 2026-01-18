import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_type_model.freezed.dart';
part 'material_type_model.g.dart';

@freezed
class MaterialTypeModel with _$MaterialTypeModel {
  const factory MaterialTypeModel({
    required int id,
    required String name,
    String? category,
    @Default(0) int displayOrder,
  }) = _MaterialTypeModel;

  factory MaterialTypeModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialTypeModelFromJson(json);
}

import 'package:equatable/equatable.dart';

class MaterialType extends Equatable {
  final int id;
  final String name;
  final String? category;
  final int displayOrder;

  const MaterialType({
    required this.id,
    required this.name,
    this.category,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, name, category, displayOrder];
}

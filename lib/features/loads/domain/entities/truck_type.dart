import 'package:equatable/equatable.dart';

class TruckType extends Equatable {
  final int id;
  final String name;
  final String? category;
  final int displayOrder;

  const TruckType({
    required this.id,
    required this.name,
    this.category,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, name, category, displayOrder];
}

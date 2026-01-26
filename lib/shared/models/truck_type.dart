/// TruckType Model
/// 
/// Represents a specific truck type selection with category and sub-options.
/// Used for load posting and filtering.

import 'package:equatable/equatable.dart';

import '../../core/constants/truck_categories.dart';
import '../../core/constants/truck_sub_options.dart';

class TruckType extends Equatable {
  final TruckCategoryId category;
  final int? lengthFt;
  final int? wheelerCount;
  final TruckAxleType? axleType;
  final TruckBodyType? bodyType;
  final MiniTruckModel? model;
  final int? passingTonMin;
  final int? passingTonMax;

  const TruckType({
    required this.category,
    this.lengthFt,
    this.wheelerCount,
    this.axleType,
    this.bodyType,
    this.model,
    this.passingTonMin,
    this.passingTonMax,
  });

  /// Create from just a category (no sub-options selected)
  factory TruckType.fromCategory(TruckCategoryId category) {
    final categoryData = getTruckCategoryById(category);
    return TruckType(
      category: category,
      passingTonMin: categoryData?.minTon,
      passingTonMax: categoryData?.maxTon,
    );
  }

  /// Get the category data
  TruckCategoryData? get categoryData => getTruckCategoryById(category);

  /// Display name for UI
  String get displayName {
    final parts = <String>[];
    
    // Category name
    parts.add(categoryData?.name ?? category.name);
    
    // Body type (for LCV)
    if (bodyType != null) {
      parts.add(bodyType!.display);
    }
    
    // Model (for Mini)
    if (model != null && model != MiniTruckModel.other) {
      parts.add(model!.display);
    }
    
    return parts.join(' ');
  }

  /// Specs string (length, wheeler, ton)
  String get specsDisplay {
    final specs = <String>[];
    
    if (lengthFt != null) {
      specs.add('$lengthFt Ft');
    }
    
    if (wheelerCount != null) {
      specs.add('$wheelerCount Wheeler');
    }
    
    if (axleType != null) {
      specs.add(axleType!.display);
    }
    
    if (passingTonMin != null && passingTonMax != null) {
      specs.add('$passingTonMin-$passingTonMax T');
    } else if (passingTonMax != null) {
      specs.add('${passingTonMax}T');
    }
    
    return specs.join(' • ');
  }

  /// Full display for load cards
  String get fullDisplay {
    final name = displayName;
    final specs = specsDisplay;
    if (specs.isEmpty) return name;
    return '$name • $specs';
  }

  /// Check if this truck type matches another (for filtering)
  bool matches(TruckType other) {
    // Category must match
    if (category != other.category) return false;
    
    // If this has specific requirements, other must meet them
    if (lengthFt != null && other.lengthFt != lengthFt) return false;
    if (wheelerCount != null && other.wheelerCount != wheelerCount) return false;
    if (axleType != null && other.axleType != axleType) return false;
    if (bodyType != null && other.bodyType != bodyType) return false;
    if (model != null && other.model != model) return false;
    
    // Ton range overlap check
    if (passingTonMin != null && passingTonMax != null &&
        other.passingTonMin != null && other.passingTonMax != null) {
      // Check if ranges overlap
      if (other.passingTonMax! < passingTonMin! || 
          other.passingTonMin! > passingTonMax!) {
        return false;
      }
    }
    
    return true;
  }

  /// Check if weight is compatible with this truck type
  bool isWeightCompatible(double weightTons) {
    if (passingTonMax == null) return true;
    return weightTons <= passingTonMax!;
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      if (lengthFt != null) 'length_ft': lengthFt,
      if (wheelerCount != null) 'wheeler_count': wheelerCount,
      if (axleType != null) 'axle_type': axleType!.name,
      if (bodyType != null) 'body_type': bodyType!.name,
      if (model != null) 'model': model!.name,
      if (passingTonMin != null) 'passing_ton_min': passingTonMin,
      if (passingTonMax != null) 'passing_ton_max': passingTonMax,
    };
  }

  /// Create from JSON
  factory TruckType.fromJson(Map<String, dynamic> json) {
    return TruckType(
      category: TruckCategoryId.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TruckCategoryId.open,
      ),
      lengthFt: json['length_ft'] as int?,
      wheelerCount: json['wheeler_count'] as int?,
      axleType: json['axle_type'] != null
          ? TruckAxleType.values.firstWhere(
              (e) => e.name == json['axle_type'],
              orElse: () => TruckAxleType.single,
            )
          : null,
      bodyType: json['body_type'] != null
          ? TruckBodyType.values.firstWhere(
              (e) => e.name == json['body_type'],
              orElse: () => TruckBodyType.open,
            )
          : null,
      model: json['model'] != null
          ? MiniTruckModel.values.firstWhere(
              (e) => e.name == json['model'],
              orElse: () => MiniTruckModel.other,
            )
          : null,
      passingTonMin: json['passing_ton_min'] as int?,
      passingTonMax: json['passing_ton_max'] as int?,
    );
  }

  /// Create a copy with modifications
  TruckType copyWith({
    TruckCategoryId? category,
    int? lengthFt,
    int? wheelerCount,
    TruckAxleType? axleType,
    TruckBodyType? bodyType,
    MiniTruckModel? model,
    int? passingTonMin,
    int? passingTonMax,
    bool clearLength = false,
    bool clearWheeler = false,
    bool clearAxle = false,
    bool clearBody = false,
    bool clearModel = false,
  }) {
    return TruckType(
      category: category ?? this.category,
      lengthFt: clearLength ? null : (lengthFt ?? this.lengthFt),
      wheelerCount: clearWheeler ? null : (wheelerCount ?? this.wheelerCount),
      axleType: clearAxle ? null : (axleType ?? this.axleType),
      bodyType: clearBody ? null : (bodyType ?? this.bodyType),
      model: clearModel ? null : (model ?? this.model),
      passingTonMin: passingTonMin ?? this.passingTonMin,
      passingTonMax: passingTonMax ?? this.passingTonMax,
    );
  }

  @override
  List<Object?> get props => [
        category,
        lengthFt,
        wheelerCount,
        axleType,
        bodyType,
        model,
        passingTonMin,
        passingTonMax,
      ];
}

/// Selection state for truck type filtering (allows multiple selections)
class TruckTypeSelection extends Equatable {
  final Set<TruckCategoryId> selectedCategories;
  final Map<TruckCategoryId, TruckType> categorySpecs;

  const TruckTypeSelection({
    this.selectedCategories = const {},
    this.categorySpecs = const {},
  });

  bool get isEmpty => selectedCategories.isEmpty;
  bool get isNotEmpty => selectedCategories.isNotEmpty;
  int get count => selectedCategories.length;

  bool hasCategory(TruckCategoryId id) => selectedCategories.contains(id);

  TruckType? getSpecsForCategory(TruckCategoryId id) => categorySpecs[id];

  TruckTypeSelection toggleCategory(TruckCategoryId id) {
    final newSet = Set<TruckCategoryId>.from(selectedCategories);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    return TruckTypeSelection(
      selectedCategories: newSet,
      categorySpecs: categorySpecs,
    );
  }

  TruckTypeSelection updateSpecs(TruckCategoryId id, TruckType specs) {
    final newSpecs = Map<TruckCategoryId, TruckType>.from(categorySpecs);
    newSpecs[id] = specs;
    return TruckTypeSelection(
      selectedCategories: selectedCategories,
      categorySpecs: newSpecs,
    );
  }

  TruckTypeSelection clear() {
    return const TruckTypeSelection();
  }

  /// Convert to list of TruckType for filtering
  List<TruckType> toTruckTypes() {
    return selectedCategories.map((id) {
      return categorySpecs[id] ?? TruckType.fromCategory(id);
    }).toList();
  }

  @override
  List<Object?> get props => [selectedCategories, categorySpecs];
}

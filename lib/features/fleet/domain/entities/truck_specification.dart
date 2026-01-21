import 'package:equatable/equatable.dart';

class TruckSpecification extends Equatable {
  final String id;
  final int tyreCount;
  final String bodyType;
  final double minCapacity;
  final double maxCapacity;
  final double? length;
  final double? width;
  final double? height;
  final List<String> specialFeatures;
  final List<String> complianceCertificates;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TruckSpecification({
    required this.id,
    required this.tyreCount,
    required this.bodyType,
    required this.minCapacity,
    required this.maxCapacity,
    this.length,
    this.width,
    this.height,
    this.specialFeatures = const [],
    this.complianceCertificates = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  TruckSpecification copyWith({
    String? id,
    int? tyreCount,
    String? bodyType,
    double? minCapacity,
    double? maxCapacity,
    double? length,
    double? width,
    double? height,
    List<String>? specialFeatures,
    List<String>? complianceCertificates,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TruckSpecification(
      id: id ?? this.id,
      tyreCount: tyreCount ?? this.tyreCount,
      bodyType: bodyType ?? this.bodyType,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      specialFeatures: specialFeatures ?? this.specialFeatures,
      complianceCertificates: complianceCertificates ?? this.complianceCertificates,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tyreCount,
        bodyType,
        minCapacity,
        maxCapacity,
        length,
        width,
        height,
        specialFeatures,
        complianceCertificates,
        isActive,
        createdAt,
        updatedAt,
      ];

  // Helper methods for UI and business logic
  String get capacityRange {
    if (minCapacity == maxCapacity) {
      return '${minCapacity.toStringAsFixed(1)} tons';
    }
    return '${minCapacity.toStringAsFixed(1)}-${maxCapacity.toStringAsFixed(1)} tons';
  }

  String get tyreCountDisplay {
    return '$tyreCount Tyres';
  }

  String get dimensions {
    if (length != null && width != null && height != null) {
      return '${length}m × ${width}m × ${height}m';
    }
    return 'Standard';
  }

  bool get isHeavyDuty {
    return tyreCount >= 16 || maxCapacity >= 16;
  }

  bool get isLightDuty {
    return tyreCount <= 6 || maxCapacity <= 5;
  }

  bool get isMediumDuty {
    return !isLightDuty && !isHeavyDuty;
  }

  // Static factory methods for common Indian truck types
  static List<TruckSpecification> getIndianTruckSpecifications() {
    return [
      // 4 Tyres - LCV
      TruckSpecification(
        id: 'spec_4_tyre_lcv',
        tyreCount: 4,
        bodyType: 'Open Body',
        minCapacity: 0.5,
        maxCapacity: 2.0,
        length: 4.0,
        width: 1.8,
        height: 2.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 6 Tyres - Small Trucks
      TruckSpecification(
        id: 'spec_6_tyre_small',
        tyreCount: 6,
        bodyType: 'Open Body',
        minCapacity: 2.0,
        maxCapacity: 5.0,
        length: 6.0,
        width: 2.2,
        height: 2.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 10 Tyres - Medium Trucks
      TruckSpecification(
        id: 'spec_10_tyre_medium',
        tyreCount: 10,
        bodyType: 'Open Body',
        minCapacity: 5.0,
        maxCapacity: 8.0,
        length: 7.5,
        width: 2.4,
        height: 3.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 12 Tyres - Medium Heavy
      TruckSpecification(
        id: 'spec_12_tyre_medium_heavy',
        tyreCount: 12,
        bodyType: 'Open Body',
        minCapacity: 8.0,
        maxCapacity: 10.0,
        length: 9.0,
        width: 2.5,
        height: 3.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 14 Tyres - Heavy
      TruckSpecification(
        id: 'spec_14_tyre_heavy',
        tyreCount: 14,
        bodyType: 'Container',
        minCapacity: 10.0,
        maxCapacity: 12.0,
        length: 10.0,
        width: 2.5,
        height: 4.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 16 Tyres - Very Heavy
      TruckSpecification(
        id: 'spec_16_tyre_very_heavy',
        tyreCount: 16,
        bodyType: 'Container',
        minCapacity: 12.0,
        maxCapacity: 16.0,
        length: 12.0,
        width: 2.5,
        height: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 18 Tyres - Ultra Heavy
      TruckSpecification(
        id: 'spec_18_tyre_ultra_heavy',
        tyreCount: 18,
        bodyType: 'Container',
        minCapacity: 16.0,
        maxCapacity: 24.0,
        length: 14.0,
        width: 2.5,
        height: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // 22+ Tyres - Super Heavy
      TruckSpecification(
        id: 'spec_22_tyre_super_heavy',
        tyreCount: 22,
        bodyType: 'Trailer',
        minCapacity: 24.0,
        maxCapacity: 42.0,
        length: 16.0,
        width: 2.5,
        height: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Simplified tyre count options for better UX
  static const List<int> tyreCounts = [4, 6, 10, 12, 14, 16, 18, 22];

  // Simplified body type options
  static const List<String> bodyTypes = [
    'Open Body',
    'Container',
    'Flatbed',
    'Tanker',
    'Specialized',
  ];

  // Simplified capacity ranges
  static const List<Map<String, dynamic>> capacityRanges = [
    {'min': 0.0, 'max': 5.0, 'label': 'Light (0-5 tons)', 'category': 'Small'},
    {'min': 5.0, 'max': 15.0, 'label': 'Medium (5-15 tons)', 'category': 'Medium'},
    {'min': 15.0, 'max': 25.0, 'label': 'Heavy (15-25 tons)', 'category': 'Heavy'},
    {'min': 25.0, 'max': 50.0, 'label': 'Super Heavy (25+ tons)', 'category': 'Super Heavy'},
  ];

  // Smart combinations based on Indian market reality
  static List<TruckSpecification> getSmartIndianTruckSpecifications() {
    return [
      // Small Trucks - Most common for city transport
      TruckSpecification(
        id: 'spec_small_open',
        tyreCount: 4,
        bodyType: 'Open Body',
        minCapacity: 0.5,
        maxCapacity: 3.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TruckSpecification(
        id: 'spec_small_container',
        tyreCount: 6,
        bodyType: 'Container',
        minCapacity: 2.0,
        maxCapacity: 5.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // Medium Trucks - Regional transport
      TruckSpecification(
        id: 'spec_medium_open',
        tyreCount: 10,
        bodyType: 'Open Body',
        minCapacity: 5.0,
        maxCapacity: 8.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TruckSpecification(
        id: 'spec_medium_container',
        tyreCount: 12,
        bodyType: 'Container',
        minCapacity: 8.0,
        maxCapacity: 12.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // Heavy Trucks - Long haul
      TruckSpecification(
        id: 'spec_heavy_container',
        tyreCount: 14,
        bodyType: 'Container',
        minCapacity: 12.0,
        maxCapacity: 16.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TruckSpecification(
        id: 'spec_heavy_flatbed',
        tyreCount: 16,
        bodyType: 'Flatbed',
        minCapacity: 15.0,
        maxCapacity: 20.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      
      // Super Heavy Trucks - Bulk transport
      TruckSpecification(
        id: 'spec_super_heavy_container',
        tyreCount: 18,
        bodyType: 'Container',
        minCapacity: 20.0,
        maxCapacity: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TruckSpecification(
        id: 'spec_super_heavy_trailer',
        tyreCount: 22,
        bodyType: 'Specialized',
        minCapacity: 25.0,
        maxCapacity: 45.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Special features
  static const List<String> specialFeaturesOptions = [
    'Hydraulic Lift',
    'Side Loading',
    'Tail Lift',
    'Refrigeration Unit',
    'GPS Tracking',
    'Sleeping Cabin',
    'Power Steering',
    'Air Conditioning',
    'Crane',
    'Winch',
  ];

  // Compliance certificates
  static const List<String> complianceOptions = [
    'RTO Registration',
    'Pollution Certificate',
    'Insurance Certificate',
    'Fitness Certificate',
    'Permit',
    'Road Tax',
    'National Permit',
    'State Permit',
  ];
}

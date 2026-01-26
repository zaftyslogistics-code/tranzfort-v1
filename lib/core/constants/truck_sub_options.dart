/// Truck Sub-Options Constants
/// 
/// Defines the sub-options available for each truck category.
/// Used in the TruckTypeSheet bottom sheet for filtering.

import 'truck_categories.dart';

/// Length options (in feet)
class TruckLengthOption {
  final int feet;
  final String display;

  const TruckLengthOption(this.feet, this.display);
}

const List<TruckLengthOption> kTruckLengthOptions = [
  TruckLengthOption(17, '17 Ft'),
  TruckLengthOption(19, '19 Ft'),
  TruckLengthOption(20, '20 Ft'),
  TruckLengthOption(22, '22 Ft'),
  TruckLengthOption(24, '24 Ft'),
  TruckLengthOption(32, '32 Ft'),
];

/// Wheeler options
class TruckWheelerOption {
  final int count;
  final String display;

  const TruckWheelerOption(this.count, this.display);
}

const List<TruckWheelerOption> kTruckWheelerOptions = [
  TruckWheelerOption(6, '6 Wheeler'),
  TruckWheelerOption(10, '10 Wheeler'),
  TruckWheelerOption(12, '12 Wheeler'),
  TruckWheelerOption(14, '14 Wheeler'),
  TruckWheelerOption(16, '16 Wheeler'),
  TruckWheelerOption(18, '18 Wheeler'),
];

/// Axle options
enum TruckAxleType {
  single('Single Axle'),
  multi('Multi Axle'),
  triple('Triple Axle');

  final String display;
  const TruckAxleType(this.display);
}

/// Body type options (for LCV)
enum TruckBodyType {
  open('Open Body'),
  container('Container'),
  covered('Covered');

  final String display;
  const TruckBodyType(this.display);
}

/// Mini truck models
enum MiniTruckModel {
  tataAce('Tata Ace'),
  mahindraPickup('Mahindra Pickup'),
  ashokLeylandDost('Ashok Leyland Dost'),
  eicher('Eicher'),
  other('Other');

  final String display;
  const MiniTruckModel(this.display);
}

/// Ton range options (predefined ranges)
class TonRangeOption {
  final int minTon;
  final int maxTon;
  final String display;

  const TonRangeOption(this.minTon, this.maxTon, this.display);
}

/// Ton ranges by category
const Map<TruckCategoryId, List<TonRangeOption>> kTonRangesByCategory = {
  TruckCategoryId.open: [
    TonRangeOption(7, 15, '7-15 T'),
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 36, '26-36 T'),
    TonRangeOption(37, 43, '37-43 T'),
  ],
  TruckCategoryId.container: [
    TonRangeOption(7, 15, '7-15 T'),
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 30, '26-30 T'),
  ],
  TruckCategoryId.lcv: [
    TonRangeOption(2, 3, '2-3 T'),
    TonRangeOption(4, 5, '4-5 T'),
    TonRangeOption(6, 7, '6-7 T'),
  ],
  TruckCategoryId.mini: [
    TonRangeOption(0, 1, '0.5-1 T'),
    TonRangeOption(1, 2, '1-2 T'),
  ],
  TruckCategoryId.trailer: [
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 36, '26-36 T'),
    TonRangeOption(37, 43, '37-43 T'),
  ],
  TruckCategoryId.tipper: [
    TonRangeOption(9, 15, '9-15 T'),
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 30, '26-30 T'),
  ],
  TruckCategoryId.tanker: [
    TonRangeOption(8, 15, '8-15 T'),
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 36, '26-36 T'),
  ],
  TruckCategoryId.dumper: [
    TonRangeOption(9, 15, '9-15 T'),
    TonRangeOption(16, 25, '16-25 T'),
    TonRangeOption(26, 36, '26-36 T'),
  ],
  TruckCategoryId.bulker: [
    TonRangeOption(20, 25, '20-25 T'),
    TonRangeOption(26, 36, '26-36 T'),
  ],
};

/// Length options by category (not all categories have length options)
const Map<TruckCategoryId, List<TruckLengthOption>> kLengthsByCategory = {
  TruckCategoryId.open: [
    TruckLengthOption(17, '17 Ft'),
    TruckLengthOption(19, '19 Ft'),
    TruckLengthOption(20, '20 Ft'),
    TruckLengthOption(22, '22 Ft'),
    TruckLengthOption(24, '24 Ft'),
  ],
  TruckCategoryId.container: [
    TruckLengthOption(19, '19 Ft'),
    TruckLengthOption(20, '20 Ft'),
    TruckLengthOption(22, '22 Ft'),
    TruckLengthOption(24, '24 Ft'),
  ],
  TruckCategoryId.lcv: [
    TruckLengthOption(14, '14 Ft'),
    TruckLengthOption(17, '17 Ft'),
    TruckLengthOption(19, '19 Ft'),
    TruckLengthOption(24, '24 Ft'),
    TruckLengthOption(32, '32 Ft SXL'),
  ],
};

/// Wheeler options by category
const Map<TruckCategoryId, List<TruckWheelerOption>> kWheelersByCategory = {
  TruckCategoryId.open: [
    TruckWheelerOption(6, '6 Wheeler'),
    TruckWheelerOption(10, '10 Wheeler'),
    TruckWheelerOption(12, '12 Wheeler'),
    TruckWheelerOption(14, '14 Wheeler'),
    TruckWheelerOption(16, '16 Wheeler'),
    TruckWheelerOption(18, '18 Wheeler'),
  ],
};

/// Get all sub-options for a category
class TruckSubOptions {
  final List<TruckLengthOption>? lengths;
  final List<TruckWheelerOption>? wheelers;
  final List<TruckAxleType>? axles;
  final List<TruckBodyType>? bodyTypes;
  final List<MiniTruckModel>? models;
  final List<TonRangeOption> tonRanges;

  const TruckSubOptions({
    this.lengths,
    this.wheelers,
    this.axles,
    this.bodyTypes,
    this.models,
    required this.tonRanges,
  });
}

TruckSubOptions getSubOptionsForCategory(TruckCategoryId categoryId) {
  return TruckSubOptions(
    lengths: kLengthsByCategory[categoryId],
    wheelers: kWheelersByCategory[categoryId],
    axles: categoryId == TruckCategoryId.container 
        ? TruckAxleType.values 
        : null,
    bodyTypes: categoryId == TruckCategoryId.lcv 
        ? TruckBodyType.values 
        : null,
    models: categoryId == TruckCategoryId.mini 
        ? MiniTruckModel.values 
        : null,
    tonRanges: kTonRangesByCategory[categoryId] ?? [],
  );
}

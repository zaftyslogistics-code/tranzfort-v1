/// Truck Categories Constants
/// 
/// Defines the 9 main truck categories used throughout the app.
/// Based on Blackbuck-style taxonomy for unified vehicle language.

/// Truck category identifiers
enum TruckCategoryId {
  open,
  container,
  lcv,
  mini,
  trailer,
  tipper,
  tanker,
  dumper,
  bulker,
}

/// Data class representing a truck category
class TruckCategoryData {
  final TruckCategoryId id;
  final String name;
  final String icon;
  final int minTon;
  final int maxTon;
  final List<TruckSubOptionType> availableSubOptions;

  const TruckCategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.minTon,
    required this.maxTon,
    required this.availableSubOptions,
  });

  String get idString => id.name;
  
  String get tonRangeDisplay => '$minTon-$maxTon T';
  
  bool matchesTonRange(int tons) => tons >= minTon && tons <= maxTon;
}

/// Types of sub-options available for truck categories
enum TruckSubOptionType {
  length,
  wheeler,
  axle,
  bodyType,
  model,
  tonRange,
}

/// All truck categories - the main constant list
const List<TruckCategoryData> kTruckCategories = [
  TruckCategoryData(
    id: TruckCategoryId.open,
    name: 'Open',
    icon: '🚛',
    minTon: 7,
    maxTon: 43,
    availableSubOptions: [
      TruckSubOptionType.length,
      TruckSubOptionType.wheeler,
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.container,
    name: 'Container',
    icon: '📦',
    minTon: 7,
    maxTon: 30,
    availableSubOptions: [
      TruckSubOptionType.length,
      TruckSubOptionType.axle,
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.lcv,
    name: 'LCV',
    icon: '🚐',
    minTon: 2,
    maxTon: 7,
    availableSubOptions: [
      TruckSubOptionType.bodyType,
      TruckSubOptionType.length,
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.mini,
    name: 'Mini/Pickup',
    icon: '🛻',
    minTon: 0,
    maxTon: 2,
    availableSubOptions: [
      TruckSubOptionType.model,
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.trailer,
    name: 'Trailer',
    icon: '🚚',
    minTon: 16,
    maxTon: 43,
    availableSubOptions: [
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.tipper,
    name: 'Tipper',
    icon: '⬆️',
    minTon: 9,
    maxTon: 30,
    availableSubOptions: [
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.tanker,
    name: 'Tanker',
    icon: '🛢️',
    minTon: 8,
    maxTon: 36,
    availableSubOptions: [
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.dumper,
    name: 'Dumper',
    icon: '🏗️',
    minTon: 9,
    maxTon: 36,
    availableSubOptions: [
      TruckSubOptionType.tonRange,
    ],
  ),
  TruckCategoryData(
    id: TruckCategoryId.bulker,
    name: 'Bulker',
    icon: '🌾',
    minTon: 20,
    maxTon: 36,
    availableSubOptions: [
      TruckSubOptionType.tonRange,
    ],
  ),
];

/// Primary categories shown in chip bar (first 4)
const List<TruckCategoryId> kPrimaryTruckCategories = [
  TruckCategoryId.open,
  TruckCategoryId.container,
  TruckCategoryId.lcv,
  TruckCategoryId.mini,
];

/// Secondary categories shown in "More" bottom sheet
const List<TruckCategoryId> kSecondaryTruckCategories = [
  TruckCategoryId.trailer,
  TruckCategoryId.tipper,
  TruckCategoryId.tanker,
  TruckCategoryId.dumper,
  TruckCategoryId.bulker,
];

/// Helper functions
TruckCategoryData? getTruckCategoryById(TruckCategoryId id) {
  try {
    return kTruckCategories.firstWhere((cat) => cat.id == id);
  } catch (_) {
    return null;
  }
}

TruckCategoryData? getTruckCategoryByIdString(String idString) {
  try {
    final id = TruckCategoryId.values.firstWhere((e) => e.name == idString);
    return getTruckCategoryById(id);
  } catch (_) {
    return null;
  }
}

List<TruckCategoryData> getTruckCategoriesByTonRange(int tons) {
  return kTruckCategories.where((cat) => cat.matchesTonRange(tons)).toList();
}

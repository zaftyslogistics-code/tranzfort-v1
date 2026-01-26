/// Material Types Constants
/// 
/// Defines the top 20 common material types for load posting.
/// Simplified from 100+ options to reduce selection friction.

/// Data class representing a material type
class MaterialTypeData {
  final String id;
  final String name;
  final String icon;
  final bool allowsCustomInput;

  const MaterialTypeData({
    required this.id,
    required this.name,
    required this.icon,
    this.allowsCustomInput = false,
  });
}

/// Top 20 common material types
const List<MaterialTypeData> kCommonMaterialTypes = [
  MaterialTypeData(
    id: 'coal',
    name: 'Coal',
    icon: '⚫',
  ),
  MaterialTypeData(
    id: 'steel_iron',
    name: 'Steel/Iron',
    icon: '🔩',
  ),
  MaterialTypeData(
    id: 'cement',
    name: 'Cement',
    icon: '🧱',
  ),
  MaterialTypeData(
    id: 'rice_grains',
    name: 'Rice/Grains',
    icon: '🌾',
  ),
  MaterialTypeData(
    id: 'sugar',
    name: 'Sugar',
    icon: '🍬',
  ),
  MaterialTypeData(
    id: 'fertilizer',
    name: 'Fertilizer',
    icon: '🌱',
  ),
  MaterialTypeData(
    id: 'cotton',
    name: 'Cotton',
    icon: '☁️',
  ),
  MaterialTypeData(
    id: 'timber_wood',
    name: 'Timber/Wood',
    icon: '🪵',
  ),
  MaterialTypeData(
    id: 'chemicals',
    name: 'Chemicals',
    icon: '🧪',
  ),
  MaterialTypeData(
    id: 'petroleum',
    name: 'Petroleum Products',
    icon: '🛢️',
  ),
  MaterialTypeData(
    id: 'machinery',
    name: 'Machinery/Equipment',
    icon: '⚙️',
  ),
  MaterialTypeData(
    id: 'automobiles',
    name: 'Automobiles/Parts',
    icon: '🚗',
  ),
  MaterialTypeData(
    id: 'textiles',
    name: 'Textiles',
    icon: '🧵',
  ),
  MaterialTypeData(
    id: 'paper_packaging',
    name: 'Paper/Packaging',
    icon: '📦',
  ),
  MaterialTypeData(
    id: 'food_products',
    name: 'Food Products',
    icon: '🍎',
  ),
  MaterialTypeData(
    id: 'pharmaceuticals',
    name: 'Pharmaceuticals',
    icon: '💊',
  ),
  MaterialTypeData(
    id: 'construction',
    name: 'Construction Materials',
    icon: '🏗️',
  ),
  MaterialTypeData(
    id: 'agricultural',
    name: 'Agricultural Products',
    icon: '🚜',
  ),
  MaterialTypeData(
    id: 'electronics',
    name: 'Electronics',
    icon: '📱',
  ),
  MaterialTypeData(
    id: 'other',
    name: 'Other',
    icon: '📝',
    allowsCustomInput: true,
  ),
];

/// Helper function to get material type by ID
MaterialTypeData? getMaterialTypeById(String id) {
  try {
    return kCommonMaterialTypes.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
}

/// Helper function to search materials by name
List<MaterialTypeData> searchMaterialTypes(String query) {
  if (query.isEmpty) return kCommonMaterialTypes;
  
  final lowerQuery = query.toLowerCase();
  return kCommonMaterialTypes
      .where((m) => m.name.toLowerCase().contains(lowerQuery))
      .toList();
}

/// Key for storing recent materials in local storage
const String kRecentMaterialsKey = 'recent_material_types';

/// Maximum number of recent materials to store
const int kMaxRecentMaterials = 5;

/// Load Validator
/// 
/// Validation functions for load posting form.
/// Returns null if valid, error message if invalid.

import '../../../../shared/widgets/price_display.dart';

class LoadValidator {
  LoadValidator._();

  static String? validateFromLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter loading point';
    }
    return null;
  }

  static String? validateToLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter unloading point';
    }
    return null;
  }

  static String? validateFromCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter loading city';
    }
    return null;
  }

  static String? validateToCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter unloading city';
    }
    return null;
  }

  static String? validateSameLocation(String? fromCity, String? toCity) {
    if (fromCity == null || toCity == null) return null;
    if (fromCity.trim().toLowerCase() == toCity.trim().toLowerCase()) {
      return 'Loading and unloading points cannot be the same';
    }
    return null;
  }

  static String? validateMaterialType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Select material type';
    }
    return null;
  }

  static String? validateCustomMaterial(String? materialId, String? customName) {
    if (materialId == 'other' && (customName == null || customName.trim().isEmpty)) {
      return 'Enter material name';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter load weight';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Enter a valid number';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    if (weight > 100) {
      return 'Weight seems too high. Please verify.';
    }
    return null;
  }

  static String? validateTruckType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Select truck type';
    }
    return null;
  }

  static String? validatePriceType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Select price type';
    }
    final validTypes = ['per_ton', 'fixed', 'negotiable'];
    if (!validTypes.contains(value)) {
      return 'Invalid price type';
    }
    return null;
  }

  static String? validateRatePerTon(String? value, PriceType priceType) {
    if (priceType != PriceType.perTon) return null;
    
    if (value == null || value.trim().isEmpty) {
      return 'Enter rate per ton';
    }
    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Enter a valid number';
    }
    if (rate <= 0) {
      return 'Rate must be greater than 0';
    }
    if (rate > 100000) {
      return 'Rate seems too high. Please verify.';
    }
    return null;
  }

  static String? validateFixedPrice(String? value, PriceType priceType) {
    if (priceType != PriceType.fixed) return null;
    
    if (value == null || value.trim().isEmpty) {
      return 'Enter total price';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Enter a valid number';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  static String? validateAdvancePercent(int? value) {
    if (value == null) return null;
    if (value < 10) {
      return 'Advance must be at least 10%';
    }
    if (value > 90) {
      return 'Advance cannot exceed 90%';
    }
    return null;
  }

  static String? validateLoadingDate(DateTime? value) {
    if (value == null) {
      return null; // Loading date is optional
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    if (selectedDate.isBefore(today)) {
      return 'Loading date cannot be in the past';
    }
    return null;
  }

  /// Check if weight is compatible with truck capacity
  static String? validateWeightForTruck({
    required double? weight,
    required int? truckMaxTon,
  }) {
    if (weight == null || truckMaxTon == null) return null;
    if (weight > truckMaxTon) {
      return 'Weight ($weight tons) may exceed truck capacity ($truckMaxTon tons)';
    }
    return null;
  }

  /// Validate entire load form
  static List<String> validateLoadForm({
    required String? fromCity,
    required String? toCity,
    required String? fromLocation,
    required String? toLocation,
    required String? materialType,
    required String? customMaterial,
    required String? weight,
    required String? truckType,
    required PriceType priceType,
    required String? ratePerTon,
    required String? fixedPrice,
    required int? advancePercent,
    required DateTime? loadingDate,
  }) {
    final errors = <String>[];

    _addIfNotNull(errors, validateFromCity(fromCity));
    _addIfNotNull(errors, validateToCity(toCity));
    _addIfNotNull(errors, validateSameLocation(fromCity, toCity));
    _addIfNotNull(errors, validateMaterialType(materialType));
    _addIfNotNull(errors, validateCustomMaterial(materialType, customMaterial));
    _addIfNotNull(errors, validateWeight(weight));
    _addIfNotNull(errors, validateTruckType(truckType));
    _addIfNotNull(errors, validateRatePerTon(ratePerTon, priceType));
    _addIfNotNull(errors, validateFixedPrice(fixedPrice, priceType));
    _addIfNotNull(errors, validateAdvancePercent(advancePercent));
    _addIfNotNull(errors, validateLoadingDate(loadingDate));

    return errors;
  }

  static void _addIfNotNull(List<String> list, String? value) {
    if (value != null) list.add(value);
  }
}

/// Extension for easy validation on strings
extension StringValidation on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

class Validators {
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    }
    if (value.length != 10) {
      return 'Please enter valid 10-digit number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter only numbers';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length != 6) {
      return 'Please enter complete 6-digit OTP';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter only numbers';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter valid email';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Price is optional
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Weight is optional
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter valid weight';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    return null;
  }
}

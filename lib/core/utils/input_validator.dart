import 'package:flutter/foundation.dart';

/// Input validation and sanitization utility
/// Prevents XSS, injection attacks, and ensures data quality
class InputValidator {
  // Maximum lengths for different input types
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 500;
  static const int maxDescriptionLength = 2000;
  static const int maxTruckNumberLength = 20;
  static const int maxNotesLength = 1000;

  /// Sanitize string input by removing potentially harmful characters
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove script tags and content
    sanitized = sanitized.replaceAll(
        RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
            caseSensitive: false),
        '');

    // Remove potentially harmful characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>]'), '');

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Validate and sanitize name input
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final sanitized = sanitize(value);

    if (sanitized.length > maxNameLength) {
      return '$fieldName must be less than $maxNameLength characters';
    }

    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(sanitized)) {
      return '$fieldName can only contain letters, spaces, and periods';
    }

    return null;
  }

  /// Validate and sanitize email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final sanitized = sanitize(value);

    if (sanitized.length > maxEmailLength) {
      return 'Email must be less than $maxEmailLength characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(sanitized)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final sanitized = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (sanitized.length > maxPhoneLength) {
      return 'Phone number is too long';
    }

    if (!RegExp(r'^\+?[\d]{10,15}$').hasMatch(sanitized)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  /// Validate truck number
  static String? validateTruckNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Truck number is required';
    }

    final sanitized = sanitize(value.toUpperCase());

    if (sanitized.length > maxTruckNumberLength) {
      return 'Truck number must be less than $maxTruckNumberLength characters';
    }

    // Indian truck number format: XX-00-XX-0000 or similar
    if (!RegExp(r'^[A-Z0-9\-]{6,20}$').hasMatch(sanitized)) {
      return 'Enter a valid truck number (e.g., MH-12-AB-1234)';
    }

    return null;
  }

  /// Validate and sanitize address
  static String? validateAddress(String? value,
      {String fieldName = 'Address'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final sanitized = sanitize(value);

    if (sanitized.length > maxAddressLength) {
      return '$fieldName must be less than $maxAddressLength characters';
    }

    if (sanitized.length < 10) {
      return '$fieldName must be at least 10 characters';
    }

    return null;
  }

  /// Validate and sanitize description/notes
  static String? validateDescription(String? value,
      {String fieldName = 'Description', bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final sanitized = sanitize(value);

    if (sanitized.length > maxDescriptionLength) {
      return '$fieldName must be less than $maxDescriptionLength characters';
    }

    return null;
  }

  /// Validate numeric input
  static String? validateNumber(
    String? value, {
    String fieldName = 'Value',
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }

    return null;
  }

  /// Validate capacity (tons)
  static String? validateCapacity(String? value) {
    return validateNumber(
      value,
      fieldName: 'Capacity',
      min: 0.1,
      max: 100.0,
      required: true,
    );
  }

  /// Validate weight (tons)
  static String? validateWeight(String? value, {bool required = true}) {
    return validateNumber(
      value,
      fieldName: 'Weight',
      min: 0.1,
      max: 100.0,
      required: required,
    );
  }

  /// Validate price
  static String? validatePrice(String? value, {bool required = false}) {
    return validateNumber(
      value,
      fieldName: 'Price',
      min: 0,
      max: 10000000,
      required: required,
    );
  }

  /// Sanitize chat message
  static String sanitizeChatMessage(String message) {
    if (message.isEmpty) return message;

    // Remove HTML and scripts
    String sanitized = sanitize(message);

    // Limit length
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }

    return sanitized;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Check if string contains SQL injection patterns
  static bool containsSQLInjection(String input) {
    final sqlPatterns = [
      RegExp(
          r'(\bSELECT\b|\bINSERT\b|\bUPDATE\b|\bDELETE\b|\bDROP\b|\bCREATE\b|\bALTER\b)',
          caseSensitive: false),
      RegExp(r'(--|;|\/\*|\*\/|xp_|sp_)', caseSensitive: false),
      RegExp(r'(\bUNION\b|\bEXEC\b|\bEXECUTE\b)', caseSensitive: false),
    ];

    return sqlPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Check if string contains XSS patterns
  static bool containsXSS(String input) {
    final xssPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
      RegExp(r'onload=', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
    ];

    return xssPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Comprehensive validation check
  static bool isSafeInput(String input) {
    return !containsSQLInjection(input) && !containsXSS(input);
  }

  /// Log suspicious input attempts
  static void logSuspiciousInput(String input, String context) {
    if (kDebugMode) {
      if (containsSQLInjection(input)) {
        print(
            '[SECURITY] Possible SQL injection attempt in $context: ${input.substring(0, input.length > 50 ? 50 : input.length)}...');
      }
      if (containsXSS(input)) {
        print(
            '[SECURITY] Possible XSS attempt in $context: ${input.substring(0, input.length > 50 ? 50 : input.length)}...');
      }
    }
  }
}

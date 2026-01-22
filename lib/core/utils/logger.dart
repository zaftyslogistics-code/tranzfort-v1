import 'package:flutter/foundation.dart';

class Logger {
  // Sensitive keywords that should never be logged
  static const _sensitiveKeywords = [
    'password',
    'token',
    'secret',
    'api_key',
    'apikey',
    'authorization',
    'bearer',
    'credit_card',
    'ssn',
    'aadhaar',
    'pan',
  ];

  // Sanitize message to remove sensitive data
  static String _sanitize(String message) {
    String sanitized = message;
    for (final keyword in _sensitiveKeywords) {
      if (sanitized.toLowerCase().contains(keyword)) {
        // Redact the value after the sensitive keyword
        final regex = RegExp(
          '($keyword[\\s:=]+)[^\\s,}\\]]+',
          caseSensitive: false,
        );
        sanitized = sanitized.replaceAllMapped(
          regex,
          (match) => '${match.group(1)}[REDACTED]',
        );
      }
    }
    return sanitized;
  }

  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] ${_sanitize(message)}');
    }
  }

  static void error(String message,
      {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[$tag] ${_sanitize(message)}');
      if (error != null) {
        print('Error details: ${_sanitize(error.toString())}');
      }
      if (stackTrace != null && kDebugMode) {
        // Only print stack trace in debug mode, not in profile/release
        print('Stack trace: $stackTrace');
      }
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      print('[$tag] ${_sanitize(message)}');
    }
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      print('[$tag] ${_sanitize(message)}');
    }
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    if (kDebugMode) {
      print('[$tag] ${_sanitize(message)}');
    }
  }
}

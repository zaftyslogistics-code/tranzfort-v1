import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void error(String message, {String tag = 'ERROR', Object? error}) {
    if (kDebugMode) {
      print('[$tag] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }
}

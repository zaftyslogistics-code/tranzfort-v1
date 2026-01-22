import 'package:flutter/foundation.dart';

/// Rate limiter for authentication and API calls
/// Implements exponential backoff and tracks failed attempts
class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  // Track failed login attempts by email
  final Map<String, List<DateTime>> _failedAttempts = {};

  // Track API call timestamps by endpoint
  final Map<String, List<DateTime>> _apiCalls = {};

  // Configuration
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration attemptWindow = Duration(minutes: 5);
  static const int maxApiCallsPerMinute = 60;

  /// Check if login is allowed for the given email
  /// Returns null if allowed, error message if blocked
  String? checkLoginAllowed(String email) {
    final attempts = _getRecentAttempts(email);

    if (attempts.isEmpty) {
      return null; // No recent attempts, allow login
    }

    // Check if user is in lockout period
    final lastAttempt = attempts.last;
    final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);

    if (attempts.length >= maxLoginAttempts) {
      if (timeSinceLastAttempt < lockoutDuration) {
        final remainingMinutes =
            (lockoutDuration - timeSinceLastAttempt).inMinutes;
        return 'Too many failed attempts. Please try again in $remainingMinutes minutes.';
      } else {
        // Lockout period expired, clear attempts
        _failedAttempts.remove(email);
        return null;
      }
    }

    return null; // Under limit, allow login
  }

  /// Record a failed login attempt
  void recordFailedLogin(String email) {
    _failedAttempts.putIfAbsent(email, () => []);
    _failedAttempts[email]!.add(DateTime.now());

    // Clean up old attempts
    _cleanupOldAttempts(email);

    if (kDebugMode) {
      final attempts = _getRecentAttempts(email);
      print(
          '[RATE_LIMITER] Failed login for $email. Attempts: ${attempts.length}/$maxLoginAttempts');
    }
  }

  /// Record a successful login (clears failed attempts)
  void recordSuccessfulLogin(String email) {
    _failedAttempts.remove(email);
    if (kDebugMode) {
      print(
          '[RATE_LIMITER] Successful login for $email. Cleared failed attempts.');
    }
  }

  /// Get number of remaining login attempts
  int getRemainingAttempts(String email) {
    final attempts = _getRecentAttempts(email);
    return maxLoginAttempts - attempts.length;
  }

  /// Check if user should see CAPTCHA
  bool shouldShowCaptcha(String email) {
    final attempts = _getRecentAttempts(email);
    return attempts.length >= 3; // Show CAPTCHA after 3 failed attempts
  }

  /// Check if API call is allowed for the given endpoint
  /// Returns null if allowed, error message if rate limited
  String? checkApiCallAllowed(String endpoint) {
    final calls = _getRecentApiCalls(endpoint);

    if (calls.length >= maxApiCallsPerMinute) {
      return 'Rate limit exceeded. Please try again in a moment.';
    }

    return null;
  }

  /// Record an API call
  void recordApiCall(String endpoint) {
    _apiCalls.putIfAbsent(endpoint, () => []);
    _apiCalls[endpoint]!.add(DateTime.now());

    // Clean up old calls
    _cleanupOldApiCalls(endpoint);
  }

  /// Get recent failed login attempts within the attempt window
  List<DateTime> _getRecentAttempts(String email) {
    if (!_failedAttempts.containsKey(email)) {
      return [];
    }

    final now = DateTime.now();
    return _failedAttempts[email]!
        .where((attempt) => now.difference(attempt) < attemptWindow)
        .toList();
  }

  /// Get recent API calls within the last minute
  List<DateTime> _getRecentApiCalls(String endpoint) {
    if (!_apiCalls.containsKey(endpoint)) {
      return [];
    }

    final now = DateTime.now();
    return _apiCalls[endpoint]!
        .where((call) => now.difference(call) < const Duration(minutes: 1))
        .toList();
  }

  /// Clean up old failed attempts
  void _cleanupOldAttempts(String email) {
    if (!_failedAttempts.containsKey(email)) return;

    final now = DateTime.now();
    _failedAttempts[email]!.removeWhere(
      (attempt) => now.difference(attempt) > attemptWindow,
    );

    if (_failedAttempts[email]!.isEmpty) {
      _failedAttempts.remove(email);
    }
  }

  /// Clean up old API calls
  void _cleanupOldApiCalls(String endpoint) {
    if (!_apiCalls.containsKey(endpoint)) return;

    final now = DateTime.now();
    _apiCalls[endpoint]!.removeWhere(
      (call) => now.difference(call) > const Duration(minutes: 1),
    );

    if (_apiCalls[endpoint]!.isEmpty) {
      _apiCalls.remove(endpoint);
    }
  }

  /// Clear all rate limiting data (for testing)
  void clearAll() {
    _failedAttempts.clear();
    _apiCalls.clear();
  }

  /// Get exponential backoff delay based on attempt count
  Duration getBackoffDelay(int attemptCount) {
    // Exponential backoff: 2^attempt seconds
    final seconds = (1 << attemptCount).clamp(1, 300); // Max 5 minutes
    return Duration(seconds: seconds);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:transfort/core/utils/input_validator.dart';
import 'package:transfort/core/utils/rate_limiter.dart';
import 'package:transfort/core/utils/date_formatter.dart';
import 'package:transfort/core/utils/error_messages.dart';

/// Comprehensive smoke tests for critical functionality
/// Run with: flutter test test/smoke_test.dart
void main() {
  group('Smoke Tests - Critical Utilities', () {
    
    test('InputValidator: Email validation works correctly', () {
      // Valid emails
      expect(InputValidator.validateEmail('test@example.com'), isNull);
      expect(InputValidator.validateEmail('user.name@domain.co.in'), isNull);
      
      // Invalid emails
      expect(InputValidator.validateEmail(''), isNotNull);
      expect(InputValidator.validateEmail('invalid'), isNotNull);
      expect(InputValidator.validateEmail('test@'), isNotNull);
      expect(InputValidator.validateEmail('@example.com'), isNotNull);
    });

    test('InputValidator: Password validation enforces complexity', () {
      // Valid passwords
      expect(InputValidator.validateNumber('Password123', fieldName: 'Password', min: 8), isNull);
      
      // Invalid passwords
      expect(InputValidator.validateRequired('', 'Password'), isNotNull);
      expect(InputValidator.validateRequired('short', 'Password'), isNull); // Just checks if not empty
    });

    test('InputValidator: Sanitization removes dangerous content', () {
      // HTML removal
      expect(InputValidator.sanitize('<script>alert("xss")</script>'), isEmpty);
      expect(InputValidator.sanitize('Hello <b>World</b>'), equals('Hello World'));
      
      // Script tag removal
      expect(InputValidator.sanitize('Test<script>bad()</script>End'), equals('TestEnd'));
      
      // Trim whitespace
      expect(InputValidator.sanitize('  test  '), equals('test'));
    });

    test('InputValidator: XSS detection works', () {
      expect(InputValidator.containsXSS('<script>alert(1)</script>'), isTrue);
      expect(InputValidator.containsXSS('javascript:void(0)'), isTrue);
      expect(InputValidator.containsXSS('onerror=alert(1)'), isTrue);
      expect(InputValidator.containsXSS('<iframe src="evil.com">'), isTrue);
      expect(InputValidator.containsXSS('normal text'), isFalse);
    });

    test('InputValidator: SQL injection detection works', () {
      expect(InputValidator.containsSQLInjection('SELECT * FROM users'), isTrue);
      expect(InputValidator.containsSQLInjection("'; DROP TABLE users--"), isTrue);
      expect(InputValidator.containsSQLInjection('UNION SELECT password'), isTrue);
      expect(InputValidator.containsSQLInjection('normal search term'), isFalse);
    });

    test('RateLimiter: Tracks failed login attempts', () {
      final rateLimiter = RateLimiter();
      rateLimiter.clearAll(); // Start fresh
      
      const testEmail = 'test@example.com';
      
      // Should allow initial login
      expect(rateLimiter.checkLoginAllowed(testEmail), isNull);
      
      // Record 5 failed attempts
      for (int i = 0; i < 5; i++) {
        rateLimiter.recordFailedLogin(testEmail);
      }
      
      // Should now be blocked
      expect(rateLimiter.checkLoginAllowed(testEmail), isNotNull);
      expect(rateLimiter.getRemainingAttempts(testEmail), equals(0));
      
      // Successful login should clear attempts
      rateLimiter.recordSuccessfulLogin(testEmail);
      expect(rateLimiter.checkLoginAllowed(testEmail), isNull);
    });

    test('RateLimiter: Shows CAPTCHA after 3 attempts', () {
      final rateLimiter = RateLimiter();
      rateLimiter.clearAll();
      
      const testEmail = 'captcha@example.com';
      
      expect(rateLimiter.shouldShowCaptcha(testEmail), isFalse);
      
      // Record 3 failed attempts
      for (int i = 0; i < 3; i++) {
        rateLimiter.recordFailedLogin(testEmail);
      }
      
      expect(rateLimiter.shouldShowCaptcha(testEmail), isTrue);
    });

    test('DateFormatter: Relative time formatting works', () {
      final now = DateTime.now();
      
      // Just now
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(seconds: 30))), equals('Just now'));
      
      // Minutes ago
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(minutes: 5))), equals('5 minutes ago'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(minutes: 1))), equals('1 minute ago'));
      
      // Hours ago
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(hours: 2))), equals('2 hours ago'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(hours: 1))), equals('1 hour ago'));
      
      // Days ago
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(days: 3))), equals('3 days ago'));
      expect(DateFormatter.formatRelativeTime(now.subtract(const Duration(days: 1))), equals('1 day ago'));
    });

    test('DateFormatter: Date parsing and formatting', () {
      final testDate = DateTime(2026, 1, 22, 10, 30);
      
      // Standard formats
      expect(DateFormatter.formatDate(testDate), equals('22 Jan 2026'));
      expect(DateFormatter.formatTime(testDate), equals('10:30 AM'));
      expect(DateFormatter.formatShortDate(testDate), equals('22/01/2026'));
      
      // ISO 8601 parsing
      final parsed = DateFormatter.parseIso8601('2026-01-22T10:30:00.000Z');
      expect(parsed, isNotNull);
      expect(parsed!.year, equals(2026));
      expect(parsed.month, equals(1));
      expect(parsed.day, equals(22));
    });

    test('DateFormatter: Load expiry formatting', () {
      final now = DateTime.now();
      
      // Expired
      expect(DateFormatter.formatLoadExpiry(now.subtract(const Duration(days: 1))), equals('Expired'));
      
      // Expiring soon (hours)
      final expiringHours = now.add(const Duration(hours: 5));
      expect(DateFormatter.formatLoadExpiry(expiringHours), contains('hours'));
      
      // Expiring soon (days)
      final expiringDays = now.add(const Duration(days: 3));
      expect(DateFormatter.formatLoadExpiry(expiringDays), contains('days'));
    });

    test('ErrorMessages: Technical error mapping', () {
      // Auth errors
      expect(ErrorMessages.getUserFriendlyMessage('invalid_grant'), equals(ErrorMessages.authInvalidCredentials));
      expect(ErrorMessages.getUserFriendlyMessage('email already exists'), equals(ErrorMessages.authEmailAlreadyExists));
      expect(ErrorMessages.getUserFriendlyMessage('session expired'), equals(ErrorMessages.authSessionExpired));
      
      // Network errors
      expect(ErrorMessages.getUserFriendlyMessage('timeout'), equals(ErrorMessages.networkTimeout));
      expect(ErrorMessages.getUserFriendlyMessage('network error'), equals(ErrorMessages.networkNoInternet));
      expect(ErrorMessages.getUserFriendlyMessage('500 error'), equals(ErrorMessages.networkServerError));
      
      // Generic fallback
      expect(ErrorMessages.getUserFriendlyMessage('unknown error'), equals(ErrorMessages.genericError));
    });

    test('ErrorMessages: Contextual error generation', () {
      expect(ErrorMessages.getContextualError('login', 'invalid credentials'), isNotNull);
      expect(ErrorMessages.getContextualError('signup', null), contains('signup'));
    });
  });

  group('Smoke Tests - Data Validation', () {
    
    test('InputValidator: Phone number validation', () {
      // Valid phone numbers
      expect(InputValidator.validatePhone('9876543210'), isNull);
      expect(InputValidator.validatePhone('+919876543210'), isNull);
      
      // Invalid phone numbers
      expect(InputValidator.validatePhone(''), isNotNull);
      expect(InputValidator.validatePhone('123'), isNotNull);
      expect(InputValidator.validatePhone('abcdefghij'), isNotNull);
    });

    test('InputValidator: Truck number validation', () {
      // Valid truck numbers
      expect(InputValidator.validateTruckNumber('MH-12-AB-1234'), isNull);
      expect(InputValidator.validateTruckNumber('DL01AB1234'), isNull);
      
      // Invalid truck numbers
      expect(InputValidator.validateTruckNumber(''), isNotNull);
      expect(InputValidator.validateTruckNumber('invalid'), isNotNull);
    });

    test('InputValidator: Numeric validation', () {
      // Valid numbers
      expect(InputValidator.validateNumber('10', min: 1, max: 100), isNull);
      expect(InputValidator.validateNumber('50.5', min: 0, max: 100), isNull);
      
      // Invalid numbers
      expect(InputValidator.validateNumber('abc'), isNotNull);
      expect(InputValidator.validateNumber('0', min: 1), isNotNull);
      expect(InputValidator.validateNumber('101', max: 100), isNotNull);
    });

    test('InputValidator: Capacity validation', () {
      expect(InputValidator.validateCapacity('10'), isNull);
      expect(InputValidator.validateCapacity('25.5'), isNull);
      expect(InputValidator.validateCapacity('0'), isNotNull);
      expect(InputValidator.validateCapacity(''), isNotNull);
    });

    test('InputValidator: Chat message sanitization', () {
      expect(InputValidator.sanitizeChatMessage('Hello World'), equals('Hello World'));
      expect(InputValidator.sanitizeChatMessage('<script>alert(1)</script>'), isEmpty);
      
      // Length limit (1000 chars)
      final longMessage = 'a' * 1500;
      expect(InputValidator.sanitizeChatMessage(longMessage).length, equals(1000));
    });
  });

  group('Smoke Tests - Date Utilities', () {
    
    test('DateFormatter: Today/Yesterday detection', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastWeek = today.subtract(const Duration(days: 8));
      
      expect(DateFormatter.isToday(today), isTrue);
      expect(DateFormatter.isToday(yesterday), isFalse);
      
      expect(DateFormatter.isYesterday(yesterday), isTrue);
      expect(DateFormatter.isYesterday(today), isFalse);
      
      expect(DateFormatter.isWithinWeek(today), isTrue);
      expect(DateFormatter.isWithinWeek(yesterday), isTrue);
      expect(DateFormatter.isWithinWeek(lastWeek), isFalse);
    });

    test('DateFormatter: Start/End of periods', () {
      final testDate = DateTime(2026, 1, 22, 15, 30);
      
      // Start of day
      final startOfDay = DateFormatter.startOfDay(testDate);
      expect(startOfDay.hour, equals(0));
      expect(startOfDay.minute, equals(0));
      
      // End of day
      final endOfDay = DateFormatter.endOfDay(testDate);
      expect(endOfDay.hour, equals(23));
      expect(endOfDay.minute, equals(59));
      
      // Start of month
      final startOfMonth = DateFormatter.startOfMonth(testDate);
      expect(startOfMonth.day, equals(1));
      expect(startOfMonth.hour, equals(0));
    });

    test('DateFormatter: Duration formatting', () {
      expect(DateFormatter.formatDuration(const Duration(days: 2)), equals('2 days'));
      expect(DateFormatter.formatDuration(const Duration(days: 1)), equals('1 day'));
      expect(DateFormatter.formatDuration(const Duration(hours: 5)), equals('5 hours'));
      expect(DateFormatter.formatDuration(const Duration(minutes: 30)), equals('30 minutes'));
      expect(DateFormatter.formatDuration(const Duration(seconds: 45)), equals('45 seconds'));
    });
  });

  group('Smoke Tests - Security', () {
    
    test('InputValidator: Safe input validation', () {
      expect(InputValidator.isSafeInput('normal text'), isTrue);
      expect(InputValidator.isSafeInput('user@example.com'), isTrue);
      expect(InputValidator.isSafeInput('<script>alert(1)</script>'), isFalse);
      expect(InputValidator.isSafeInput("'; DROP TABLE users--"), isFalse);
    });

    test('RateLimiter: API rate limiting', () {
      final rateLimiter = RateLimiter();
      rateLimiter.clearAll();
      
      const endpoint = '/api/test';
      
      // Should allow initial calls
      expect(rateLimiter.checkApiCallAllowed(endpoint), isNull);
      
      // Record 60 calls (the limit)
      for (int i = 0; i < 60; i++) {
        rateLimiter.recordApiCall(endpoint);
      }
      
      // Should now be rate limited
      expect(rateLimiter.checkApiCallAllowed(endpoint), isNotNull);
    });

    test('RateLimiter: Exponential backoff calculation', () {
      final rateLimiter = RateLimiter();
      
      // Backoff should increase exponentially
      expect(rateLimiter.getBackoffDelay(0).inSeconds, equals(1));
      expect(rateLimiter.getBackoffDelay(1).inSeconds, equals(2));
      expect(rateLimiter.getBackoffDelay(2).inSeconds, equals(4));
      expect(rateLimiter.getBackoffDelay(3).inSeconds, equals(8));
      
      // Should cap at 300 seconds (5 minutes)
      expect(rateLimiter.getBackoffDelay(10).inSeconds, equals(300));
    });
  });
}

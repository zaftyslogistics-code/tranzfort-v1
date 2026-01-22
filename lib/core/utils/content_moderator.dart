import 'package:flutter/foundation.dart';

/// Content moderation utility for filtering inappropriate content
class ContentModerator {
  // Profanity word list (basic examples - expand as needed)
  static final Set<String> _profanityWords = {
    'badword1', 'badword2', 'badword3', // Replace with actual words
    // Add more profanity words as needed
  };

  // Spam patterns
  static final List<RegExp> _spamPatterns = [
    RegExp(r'(http|https)://[^\s]+', caseSensitive: false), // URLs
    RegExp(r'\b\d{10,}\b'), // Long number sequences (phone numbers)
    RegExp(r'(.)\1{4,}'), // Repeated characters (aaaaa)
    RegExp(r'(buy now|click here|limited offer)', caseSensitive: false),
  ];

  /// Check if text contains profanity
  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    return _profanityWords.any((word) => lowerText.contains(word));
  }

  /// Check if text is spam
  static bool isSpam(String text) {
    // Check for spam patterns
    for (final pattern in _spamPatterns) {
      if (pattern.hasMatch(text)) {
        if (kDebugMode) {
          print('[CONTENT_MODERATOR] Spam detected: ${pattern.pattern}');
        }
        return true;
      }
    }

    // Check for excessive capitalization
    final capitalCount = text.replaceAll(RegExp(r'[^A-Z]'), '').length;
    if (text.length > 10 && capitalCount / text.length > 0.7) {
      if (kDebugMode) {
        print('[CONTENT_MODERATOR] Excessive caps detected');
      }
      return true;
    }

    return false;
  }

  /// Filter profanity from text
  static String filterProfanity(String text, {String replacement = '***'}) {
    String filtered = text;
    for (final word in _profanityWords) {
      final regex = RegExp(word, caseSensitive: false);
      filtered = filtered.replaceAll(regex, replacement);
    }
    return filtered;
  }

  /// Moderate content (returns moderation result)
  static ModerationResult moderateContent(String text) {
    final hasProfanity = containsProfanity(text);
    final isSpamContent = isSpam(text);

    if (hasProfanity || isSpamContent) {
      return ModerationResult(
        isAllowed: false,
        reason: hasProfanity ? 'Contains inappropriate language' : 'Detected as spam',
        filteredText: hasProfanity ? filterProfanity(text) : text,
      );
    }

    return ModerationResult(
      isAllowed: true,
      filteredText: text,
    );
  }

  /// Check if user is posting too frequently (rate limiting)
  static bool isRateLimited(List<DateTime> recentPosts, {int maxPosts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final recentCount = recentPosts.where((time) => now.difference(time) < window).length;
    return recentCount >= maxPosts;
  }

  /// Calculate spam score (0-100, higher = more likely spam)
  static int calculateSpamScore(String text) {
    int score = 0;

    // Check for URLs
    if (RegExp(r'(http|https)://').hasMatch(text)) score += 30;

    // Check for phone numbers
    if (RegExp(r'\b\d{10,}\b').hasMatch(text)) score += 25;

    // Check for excessive caps
    final capitalCount = text.replaceAll(RegExp(r'[^A-Z]'), '').length;
    if (text.length > 10 && capitalCount / text.length > 0.5) score += 20;

    // Check for repeated characters
    if (RegExp(r'(.)\1{4,}').hasMatch(text)) score += 15;

    // Check for spam keywords
    if (RegExp(r'(buy now|click here|limited offer|free money)', caseSensitive: false).hasMatch(text)) {
      score += 40;
    }

    return score.clamp(0, 100);
  }
}

/// Moderation result class
class ModerationResult {
  final bool isAllowed;
  final String? reason;
  final String filteredText;

  ModerationResult({
    required this.isAllowed,
    this.reason,
    required this.filteredText,
  });
}

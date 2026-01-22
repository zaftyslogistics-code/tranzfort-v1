import 'package:flutter/foundation.dart';

/// Search service for filtering and searching data
class SearchService {
  /// Search loads by query
  static List<T> searchList<T>({
    required List<T> items,
    required String query,
    required String Function(T) getSearchableText,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      final searchText = getSearchableText(item).toLowerCase();
      return searchText.contains(lowerQuery);
    }).toList();
  }

  /// Search with multiple fields
  static List<T> searchMultipleFields<T>({
    required List<T> items,
    required String query,
    required List<String Function(T)> getSearchableFields,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return getSearchableFields.any((getField) {
        final fieldText = getField(item).toLowerCase();
        return fieldText.contains(lowerQuery);
      });
    }).toList();
  }

  /// Fuzzy search (allows minor typos)
  static List<T> fuzzySearch<T>({
    required List<T> items,
    required String query,
    required String Function(T) getSearchableText,
    int maxDistance = 2,
  }) {
    if (query.isEmpty) return items;

    final results = <T>[];
    for (final item in items) {
      final text = getSearchableText(item);
      final distance =
          levenshteinDistance(query.toLowerCase(), text.toLowerCase());
      if (distance <= maxDistance) {
        results.add(item);
      }
    }
    return results;
  }

  /// Calculate Levenshtein distance (edit distance) between two strings
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Highlight search query in text
  static List<TextSpan> highlightSearchQuery(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final index = lowerText.indexOf(lowerQuery, currentIndex);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex)));
        break;
      }

      if (index > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFFFEB3B),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = index + query.length;
    }

    return spans;
  }

  /// Filter list by multiple criteria
  static List<T> filterList<T>({
    required List<T> items,
    required Map<String, dynamic> filters,
    required bool Function(T item, String key, dynamic value) matchesFilter,
  }) {
    if (filters.isEmpty) return items;

    return items.where((item) {
      return filters.entries.every((entry) {
        return matchesFilter(item, entry.key, entry.value);
      });
    }).toList();
  }

  /// Sort list by field
  static List<T> sortList<T>({
    required List<T> items,
    required Comparable Function(T) getSortValue,
    bool ascending = true,
  }) {
    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      final valueA = getSortValue(a);
      final valueB = getSortValue(b);
      return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
    });
    return sorted;
  }
}

/// Text span for highlighting
class TextSpan {
  final String text;
  final TextStyle? style;

  TextSpan({required this.text, this.style});
}

/// Text style for highlighting
class TextStyle {
  final Color? backgroundColor;
  final FontWeight? fontWeight;

  const TextStyle({this.backgroundColor, this.fontWeight});
}

/// Color class
class Color {
  final int value;
  const Color(this.value);
}

/// Font weight enum
enum FontWeight {
  normal,
  bold,
}

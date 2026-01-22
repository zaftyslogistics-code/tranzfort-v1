import 'package:intl/intl.dart';

/// Utility class for consistent date and time formatting across the app
class DateFormatter {
  // Standard date formats
  static final DateFormat _dateFormat =
      DateFormat('dd MMM yyyy'); // 22 Jan 2026
  static final DateFormat _dateTimeFormat =
      DateFormat('dd MMM yyyy, hh:mm a'); // 22 Jan 2026, 10:30 PM
  static final DateFormat _timeFormat = DateFormat('hh:mm a'); // 10:30 PM
  static final DateFormat _shortDateFormat =
      DateFormat('dd/MM/yyyy'); // 22/01/2026
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy'); // Jan 2026
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM'); // 22 Jan

  /// Format date as "22 Jan 2026"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date and time as "22 Jan 2026, 10:30 PM"
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format time as "10:30 PM"
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Format date as "22/01/2026"
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format as "Jan 2026"
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format as "22 Jan"
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Format as relative time: "Just now", "2 minutes ago", "3 hours ago", etc.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format as smart relative time with fallback to date
  /// "Just now", "2 hours ago", or "22 Jan 2026" if older than 7 days
  static String formatSmartRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 7) {
      return formatRelativeTime(dateTime);
    } else if (difference.inDays < 365) {
      return formatDayMonth(dateTime);
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format chat message timestamp
  /// Shows time if today, date if this year, full date if older
  static String formatChatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return formatTime(dateTime);
    } else if (dateTime.year == now.year) {
      return formatDayMonth(dateTime);
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format load expiry date with warning if expiring soon
  static String formatLoadExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Expires in $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Expires in $days ${days == 1 ? 'day' : 'days'}';
    } else {
      return 'Expires on ${formatDate(expiryDate)}';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is within the last 7 days
  static bool isWithinWeek(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays < 7;
  }

  /// Format duration in human-readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '${duration.inSeconds} ${duration.inSeconds == 1 ? 'second' : 'seconds'}';
    }
  }

  /// Parse ISO 8601 string to DateTime
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format for API submission (ISO 8601)
  static String formatForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(monday);
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return endOfDay(sunday);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }
}

import 'package:intl/intl.dart';

/// Date utility functions
class DateUtils {
  const DateUtils._();

  static final DateFormat _monthDayFormat = DateFormat('MMM d');
  static final DateFormat _monthDayYearFormat = DateFormat('MMM d, y');
  static final DateFormat _monthYearFormat = DateFormat('MMMM y');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _fullDateTimeFormat = DateFormat('MMM d, y HH:mm');

  /// Format date as 'Jan 1'
  static String formatMonthDay(DateTime date) {
    return _monthDayFormat.format(date);
  }

  /// Format date as 'Jan 1, 2024'
  static String formatMonthDayYear(DateTime date) {
    return _monthDayYearFormat.format(date);
  }

  /// Format date as 'January 2024'
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format time as '14:30'
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format date and time as 'Jan 1, 2024 14:30'
  static String formatFullDateTime(DateTime date) {
    return _fullDateTimeFormat.format(date);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
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

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatMonthDayYear(date);
  }
}

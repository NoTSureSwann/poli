import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '-';
    try {
      final time = DateTime.parse('2000-01-01 $timeString');
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return '-';
    }
  }

  static String formatDateShort(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  static bool isToday(String? dateString) {
    if (dateString == null) return false;
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }
}

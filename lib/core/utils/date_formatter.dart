import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static DateTime toWib(DateTime date) {
    final utc = date.isUtc ? date : date.toUtc();
    return utc.add(const Duration(hours: 7));
  }

  static String formatDate(DateTime date) {
    final wib = toWib(date);
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(wib);
    } catch (_) {
      final day = wib.day.toString().padLeft(2, '0');
      final month = _months[wib.month - 1];
      return '$day $month ${wib.year}';
    }
  }

  static String formatDateTime(DateTime date, {bool showWib = true}) {
    final wib = toWib(date);
    try {
      final formatted = DateFormat('dd MMM yyyy, HH.mm', 'id_ID').format(wib);
      return showWib ? '$formatted WIB' : formatted;
    } catch (_) {
      final day = wib.day.toString().padLeft(2, '0');
      final month = _months[wib.month - 1];
      final hour = wib.hour.toString().padLeft(2, '0');
      final minute = wib.minute.toString().padLeft(2, '0');
      final formatted = '$day $month ${wib.year}, $hour.$minute';
      return showWib ? '$formatted WIB' : formatted;
    }
  }

  /// Format rentang tanggal: 01 Okt 2026 - 23 Okt 2026
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }
}

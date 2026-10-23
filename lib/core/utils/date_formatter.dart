import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static DateTime toWib(DateTime date) {
    final utc = date.isUtc ? date : date.toUtc();
    return utc.add(const Duration(hours: 7));
  }

  static String formatDate(DateTime date) {
    final wib = toWib(date);
    return DateFormat('dd MMM yyyy', 'id_ID').format(wib);
  }

  static String formatDateTime(DateTime date, {bool showWib = true}) {
    final wib = toWib(date);
    final formatted = DateFormat('dd MMM yyyy, HH.mm', 'id_ID').format(wib);
    return showWib ? '$formatted WIB' : formatted;
  }

  /// Format rentang tanggal: 01 Okt 2026 - 23 Okt 2026
  static String formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return '${formatter.format(toWib(start))} - ${formatter.format(toWib(end))}';
  }
}

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH.mm', 'id_ID').format(date);
  }

  static String formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}

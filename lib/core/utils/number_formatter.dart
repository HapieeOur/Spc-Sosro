import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  static String formatNumber(int value) {
    return NumberFormat('#,###', 'id_ID').format(value);
  }

  static String formatDecimal(double value, {int decimals = 2}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: decimals,
    ).format(value);
  }
}

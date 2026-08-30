import 'package:intl/intl.dart';

class MoneyUtils {
  const MoneyUtils._();

  static int parseRupeesToPaise(String value) {
    var cleaned = value.replaceAll(',', '').replaceAll('\u20B9', '').trim();

    if (cleaned.isEmpty) {
      return 0;
    }

    final negative = cleaned.startsWith('-');

    if (negative) {
      cleaned = cleaned.substring(1);
    }

    final parts = cleaned.split('.');

    final rupees =
        int.tryParse(
          parts.isEmpty || parts.first.isEmpty ? '0' : parts.first,
        ) ??
        0;

    var paise = 0;

    if (parts.length > 1) {
      var decimal = parts[1];

      if (decimal.length == 1) {
        decimal = '${decimal}0';
      }

      if (decimal.length > 2) {
        decimal = decimal.substring(0, 2);
      }

      paise = int.tryParse(decimal) ?? 0;
    }

    final result = (rupees * 100) + paise;

    return negative ? -result : result;
  }

  static int rupeesToPaise(double rupees) {
    return (rupees * 100).round();
  }

  static double paiseToRupees(int paise) {
    return paise / 100;
  }

  static String paiseToRupeesText(int paise) {
    final value = paise / 100;

    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 2,
    ).format(value).trim();
  }
}

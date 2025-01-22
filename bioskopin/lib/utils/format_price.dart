import 'package:intl/intl.dart';

class FormatPriceUtil {
  static String formatPrice(String value) {
    try {
      double price = double.parse(value);

      var formatCurrency = NumberFormat.currency(locale: 'ID', symbol: 'Rp', decimalDigits: 0);

      return formatCurrency.format(price);
    } catch (e) {
      return 'Invalid value';
    }
  }
}

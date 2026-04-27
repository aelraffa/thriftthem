import 'package:intl/intl.dart';

class DateUtils {
  static String formatPrice(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String daysAgoLabel(int days) {
    if (days == 0) return 'Added today';
    if (days == 1) return '1 day on list';
    return '$days days on list';
  }

  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }
}
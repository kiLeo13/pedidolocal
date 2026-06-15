import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static String currency(num value) => _currency.format(value);
}

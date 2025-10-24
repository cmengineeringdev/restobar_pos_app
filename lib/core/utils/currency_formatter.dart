import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  /// Format amount to Colombian currency string (e.g., "$1.000", "$15.000")
  static String format(double amount) {
    final formattedNumber = _formatter.format(amount).trim();
    return '${AppConstants.currencySymbol}$formattedNumber';
  }

  /// Format amount with decimals (e.g., "$1.000,50")
  static String formatWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '',
      decimalDigits: 2,
    );
    final formattedNumber = formatter.format(amount).trim();
    return '${AppConstants.currencySymbol}$formattedNumber';
  }

  /// Parse currency string to double
  static double parse(String currencyString) {
    final cleanString = currencyString
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll('.', '') // Remover separador de miles
        .replaceAll(',', '.') // Convertir separador decimal colombiano a punto
        .trim();
    
    return double.tryParse(cleanString) ?? 0.0;
  }
}


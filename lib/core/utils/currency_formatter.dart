import '../constants/app_constants.dart';

class CurrencyFormatter {
  /// Format amount to currency string (e.g., "$25.50")
  static String format(double amount) {
    return '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}';
  }

  /// Parse currency string to double
  static double parse(String currencyString) {
    final cleanString = currencyString
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .trim();
    
    return double.tryParse(cleanString) ?? 0.0;
  }
}


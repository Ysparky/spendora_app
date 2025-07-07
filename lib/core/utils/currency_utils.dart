import 'package:intl/intl.dart';

/// Currency utility functions
class CurrencyUtils {
  const CurrencyUtils._();

  /// Default currency code
  static const String defaultCurrency = 'PEN';

  /// Supported currencies with their symbols
  static const Map<String, String> currencySymbols = {
    'PEN': 'S/',
    'USD': '\$',
    'EUR': '€',
  };

  /// Format amount with currency symbol
  static String formatAmount(double amount, String currencyCode) {
    final format = NumberFormat.currency(
      symbol: currencySymbols[currencyCode] ?? currencyCode,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Format amount without currency symbol
  static String formatAmountOnly(double amount) {
    final format = NumberFormat.decimalPattern();
    return format.format(amount);
  }

  /// Parse amount string to double
  static double? parseAmount(String amount) {
    try {
      // Remove currency symbols and spaces
      final cleanAmount = amount.replaceAll(RegExp(r'[^\d.,]'), '');
      return double.parse(cleanAmount.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol
  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Check if currency code is supported
  static bool isSupportedCurrency(String currencyCode) {
    return currencySymbols.containsKey(currencyCode);
  }

  /// Get list of supported currency codes
  static List<String> getSupportedCurrencies() {
    return currencySymbols.keys.toList();
  }
}

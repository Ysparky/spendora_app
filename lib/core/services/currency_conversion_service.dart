import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConversionService extends ChangeNotifier {
  final String apiKey;
  final String baseUrl = 'https://api.exchangerate-api.com/v4/latest/';

  CurrencyConversionService({required this.apiKey});

  // Cache exchange rates for 1 hour
  final Map<String, Map<String, double>> _ratesCache = {};
  final Map<String, DateTime> _ratesCacheTime = {};

  /// Convert amount from one currency to another
  Future<double> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    final rates = await _getExchangeRates(fromCurrency);
    final rate = rates[toCurrency];
    if (rate == null) {
      throw Exception('Exchange rate not found for $toCurrency');
    }

    return amount * rate;
  }

  /// Get exchange rates for a base currency
  Future<Map<String, double>> _getExchangeRates(String baseCurrency) async {
    // Check cache
    if (_ratesCache.containsKey(baseCurrency)) {
      final cacheTime = _ratesCacheTime[baseCurrency];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime).inHours < 1) {
        return _ratesCache[baseCurrency]!;
      }
    }

    try {
      // Fetch new rates
      final response = await http.get(Uri.parse('$baseUrl$baseCurrency'));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch exchange rates');
      }

      final data = json.decode(response.body);
      final rawRates = data['rates'] as Map<String, dynamic>;

      // Convert all values to double, handling both int and double inputs
      final rates = rawRates.map(
        (key, value) =>
            MapEntry(key, value is int ? value.toDouble() : value as double),
      );

      // Update cache
      _ratesCache[baseCurrency] = rates;
      _ratesCacheTime[baseCurrency] = DateTime.now();

      return rates;
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      // Return cached rates if available, even if expired
      if (_ratesCache.containsKey(baseCurrency)) {
        return _ratesCache[baseCurrency]!;
      }
      rethrow;
    }
  }

  /// Format amount with conversion details
  /// Returns a tuple of (total in target currency, conversion details string)
  Future<(double, String)> getAmountWithConversionDetails({
    required Map<String, double> amounts,
    required String targetCurrency,
  }) async {
    if (amounts.isEmpty) return (0.toDouble(), '');

    double total = 0;
    final List<String> details = [];

    for (final entry in amounts.entries) {
      final currency = entry.key;
      final amount = entry.value;

      if (currency == targetCurrency) {
        total += amount;
        details.add('${amount.toStringAsFixed(2)} $currency');
      } else {
        final convertedAmount = await convertAmount(
          amount: amount,
          fromCurrency: currency,
          toCurrency: targetCurrency,
        );
        total += convertedAmount;
        details.add(
          '$currency ${amount.toStringAsFixed(2)} ≈ $targetCurrency ${convertedAmount.toStringAsFixed(2)}',
        );
      }
    }

    return (total, '(${details.join(' + ')})');
  }
}

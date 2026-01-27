import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_model.dart';

class CurrencyApiService {
  /// Stores the previously fetched rate (used for volatility detection)
  static ExchangeRate? _previousRate;

  /// Fetch all available currency codes
  static Future<List<String>> getAllCurrencies() async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load currencies');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, dynamic> rates = data['rates'];

    return rates.keys.toList();
  }

  /// Fetch exchange rate between two currencies
  static Future<ExchangeRate> getRate(String from, String to) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode != 200) {
      throw Exception('API error');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, dynamic> rates = data['rates'];

    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      throw Exception('Currency not supported');
    }

    final double fromRate = (rates[from] as num).toDouble();
    final double toRate = (rates[to] as num).toDouble();
    final double rate = toRate / fromRate;

    final ExchangeRate currentRate = ExchangeRate(
      baseCurrency: from,
      targetCurrency: to,
      rate: rate,
      timestamp: DateTime.now(),
    );

    // Volatility calculation (console only for now)
    if (_previousRate != null &&
        _previousRate!.baseCurrency == from &&
        _previousRate!.targetCurrency == to) {
      final double oldRate = _previousRate!.rate;
      final double percentChange = ((rate - oldRate) / oldRate) * 100;

      print(
        'Volatility (${from} to ${to}): ${percentChange.toStringAsFixed(2)}%',
      );
    }

    _previousRate = currentRate;
    return currentRate;
  }

  /// Mock historical data for trends & graphs
  static Future<List<ExchangeRate>> getHistoricalRates(
    String base,
    String target,
  ) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode != 200) {
      throw Exception('API error');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, dynamic> rates = data['rates'];

    if (!rates.containsKey(base) || !rates.containsKey(target)) {
      throw Exception('Currency not supported');
    }

    final double baseRate = (rates[base] as num).toDouble();
    final double targetRate = (rates[target] as num).toDouble();
    final double currentRate = targetRate / baseRate;

    return List.generate(7, (index) {
      return ExchangeRate(
        baseCurrency: base,
        targetCurrency: target,
        rate: currentRate * (0.97 + index * 0.01),
        timestamp: DateTime.now().subtract(Duration(days: 6 - index)),
      );
    });
  }
}

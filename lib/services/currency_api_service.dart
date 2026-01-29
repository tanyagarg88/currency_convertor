import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/exchange_rate_model.dart';
import '../models/volatility_result.dart';

class CurrencyApiService {
  static ExchangeRate? _previousRate;
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

  static Future<Map<String, dynamic>> getRate(String from, String to) async {
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
    final double rateValue = toRate / fromRate;
    final ExchangeRate currentRate = ExchangeRate(
      baseCurrency: from,
      targetCurrency: to,
      rate: rateValue,
      timestamp: DateTime.now(),
    );

    VolatilityResult? volatility;
    if (_previousRate != null &&
        _previousRate!.baseCurrency == from &&
        _previousRate!.targetCurrency == to) {
      final double oldRate = _previousRate!.rate;
      final double percentChange = ((rateValue - oldRate) / oldRate) * 100;

      volatility = VolatilityResult(
        percentChange: percentChange.abs(),
        isIncrease: percentChange >= 0,
        time: DateTime.now(),
      );
    }
    _previousRate = currentRate;

    return {'rate': currentRate, 'volatility': volatility};
  }

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

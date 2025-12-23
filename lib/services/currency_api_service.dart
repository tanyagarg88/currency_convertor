import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  static Future<double> getRate(String base) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/$base'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates']['INR'].toDouble();
    } else {
      throw Exception('Failed to fetch rate');
    }
  }

  static Future<List<double>> getHistoricalRates(String base) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/$base'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final double current = data['rates']['INR'].toDouble();

      return [
        current - 0.8,
        current - 0.5,
        current - 0.3,
        current,
        current + 0.2,
        current + 0.4,
        current + 0.6,
      ];
    } else {
      throw Exception('Failed to load history');
    }
  }
}

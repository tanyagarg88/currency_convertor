import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  static Future<double> getRate(String baseCurrency) async {
    final response = await http.get(
      Uri.parse("https://api.exchangerate-api.com/v4/latest/$baseCurrency"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates']['INR'];
    } else {
      throw Exception("API Error");
    }
  }
}

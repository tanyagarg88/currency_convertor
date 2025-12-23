import 'package:flutter/material.dart';
import 'currency_convertor_material_page.dart';

void main() {
  runApp(const MyApp());
}

List<double> historicalRates = [];
bool isGraphLoading = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CurrencyConvertorMaterialPage());
  }
}

import 'package:currency_convertor/services/exchange_rate_graph.dart';
import 'package:flutter/material.dart';
import '../services/currency_api_service.dart';
import '../widgets/exchange_rate_graph.dart';

class CurrencyConvertorMaterialPage extends StatefulWidget {
  const CurrencyConvertorMaterialPage({super.key});

  @override
  State<CurrencyConvertorMaterialPage> createState() =>
      _CurrencyConvertorMaterialPageState();
}

class _CurrencyConvertorMaterialPageState
    extends State<CurrencyConvertorMaterialPage> {
  double result = 0.0;
  double currentRate = 0.0;
  bool isLoading = false;

  bool showTrendCard = false;
  bool isGraphLoading = false;

  String selectedCurrency = 'USD';
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY'];

  List<double> historicalRates = [];

  final TextEditingController textEditingController = TextEditingController();
  Future<void> convertCurrency() async {
    final double amount = double.tryParse(textEditingController.text) ?? 0;

    if (amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final double rate = await CurrencyApiService.getRate(selectedCurrency);

      setState(() {
        currentRate = rate;
        result = amount * rate;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching exchange rate')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showCalculationHelp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How is this calculated?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Formula:'),
            const SizedBox(height: 4),
            const Text('Amount × Exchange Rate = Converted Value'),
            const SizedBox(height: 12),
            Text(
              '${textEditingController.text} $selectedCurrency '
              '× ${currentRate.toStringAsFixed(2)} '
              '= ${result.toStringAsFixed(2)} INR',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadHistoricalData() async {
    setState(() => isGraphLoading = true);

    try {
      final data = await CurrencyApiService.getHistoricalRates(
        selectedCurrency,
      );
      setState(() => historicalRates = data);
    } catch (_) {}

    setState(() => isGraphLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black26, width: 2),
      borderRadius: BorderRadius.circular(8),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 170, 130),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 170, 130),
        title: const Text(
          'Currency Converter',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Converted Amount',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${result.toStringAsFixed(2)} INR',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (result != 0)
                    TextButton(
                      onPressed: showCalculationHelp,
                      child: const Text(
                        'How is this calculated?',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCurrency,
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                        historicalRates.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Currency',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: border,
                      enabledBorder: border,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: convertCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Convert'),
                  ),

                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () async {
                setState(() => showTrendCard = !showTrendCard);
                if (historicalRates.isEmpty) {
                  await loadHistoricalData();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.show_chart, color: Colors.white),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 16,
            bottom: showTrendCard ? 80 : -240,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exchange Rate Insight',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 $selectedCurrency = '
                      '${currentRate.toStringAsFixed(2)} INR',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: isGraphLoading
                          ? const Center(child: CircularProgressIndicator())
                          : historicalRates.isEmpty
                          ? const Center(child: Text('No data'))
                          : ExchangeRateGraph(rates: historicalRates),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/currency_api_service.dart';

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

  String selectedCurrency = 'USD';
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY'];

  final TextEditingController textEditingController = TextEditingController();

  Future<void> convertCurrency() async {
    final double amount = double.tryParse(textEditingController.text) ?? 0;

    if (amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final double rate = await CurrencyApiService.getRate(selectedCurrency);

      setState(() {
        currentRate = rate;
        result = amount * rate;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching exchange rate')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          style: TextStyle(color: Color.fromARGB(255, 23, 3, 3), fontSize: 20),
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
                  ElevatedButton(
                    onPressed: convertCurrency,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    child: const Text('Convert'),
                  ),
                  if (result != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '${textEditingController.text} $selectedCurrency = '
                        '${result.toStringAsFixed(2)} INR',

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 2, 32, 29),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: result == 0
                        ? null
                        : () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'How is this calculated?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Formula:'),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Amount × Exchange Rate = Converted Value',
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${textEditingController.text} $selectedCurrency '
                                        '× ${currentRate.toStringAsFixed(2)} '
                                        '= ${result.toStringAsFixed(2)} INR',
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                    child: const Text(
                      'How is this calculated?',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCurrency,
                    items: currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
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
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    child: const Text('Convert'),
                  ),

                  const SizedBox(height: 160), // space for footer
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showTrendCard = !showTrendCard;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 16,
            bottom: showTrendCard ? 80 : -220,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 $selectedCurrency = '
                      '${currentRate.toStringAsFixed(2)} INR',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Trend graph will appear here',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
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

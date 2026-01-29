import 'package:currency_convertor/models/exchange_rate_model.dart';
import 'package:currency_convertor/models/volatility_result.dart';
import 'package:currency_convertor/screens/exchange_rate_insight_screen.dart';
import 'package:flutter/material.dart';
import '../services/currency_api_service.dart';
import '../screens/all_currencies_page.dart';
import '../learning/learning_mode_controller.dart';
import '../config/app_config.dart';
import '../services/fee_engine.dart';

class CurrencyConvertorMaterialPage extends StatefulWidget {
  const CurrencyConvertorMaterialPage({super.key});

  @override
  State<CurrencyConvertorMaterialPage> createState() =>
      _CurrencyConvertorMaterialPageState();
}

class _CurrencyConvertorMaterialPageState
    extends State<CurrencyConvertorMaterialPage> {
  VolatilityResult? lastVolatility;
  double result = 0.0;
  double currentRate = 0.0;
  double netResult = 0;
  bool isLoading = false;

  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  bool isSwapped = false;
  final TextEditingController textEditingController = TextEditingController();
  Future<void> convertCurrency() async {
    final amount = double.tryParse(textEditingController.text) ?? 0;

    if (amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await CurrencyApiService.getRate(
        fromCurrency,
        toCurrency,
      );

      final exchangeRate = response['rate'] as ExchangeRate;
      final volatility = response['volatility'];

      final feeAdjustedRate = FeeEngine.calculateNetRate(
        marketRate: exchangeRate.rate,
        feeModel: AppConfig.defaultFees,
      );

      setState(() {
        currentRate = exchangeRate.rate;
        result = amount * exchangeRate.rate;
        netResult = amount * feeAdjustedRate;
        // ignore: unused_local_variable
        var lastVolatility = volatility;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching exchange rate')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      isSwapped = !isSwapped;
      result = 0;
      textEditingController.clear();
    });
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
            const Text('Amount × Exchange Rate = Converted Value'),
            const SizedBox(height: 12),
            Text(
              '${textEditingController.text} $fromCurrency '
              '× ${currentRate.toStringAsFixed(2)} '
              '= ${result.toStringAsFixed(2)} $toCurrency',
            ),
            const SizedBox(height: 12),

            const Text(
              'After fees:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            Text(
              netResult.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            ExpansionTile(
              title: const Text(
                'Fee details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  title: const Text('Platform fee'),
                  trailing: Text(
                    '${AppConfig.defaultFees.platformFeePercent}%',
                  ),
                ),
                ListTile(
                  title: const Text('Bank margin'),
                  trailing: Text('${AppConfig.defaultFees.bankMarginPercent}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showFeeNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee Insight',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Final amount includes platform fee '
              '(${AppConfig.defaultFees.platformFeePercent}%) '
              'and bank margin '
              '(${AppConfig.defaultFees.bankMarginPercent}%).',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black26),
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'CurrenSense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  showFeeNotification(context);
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF7B1FA2)],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final selected = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AllCurrenciesPage(),
                                    ),
                                  );
                                  if (selected != null) {
                                    setState(() {
                                      fromCurrency = selected;
                                    });
                                  }
                                },
                                child: _currencyCard(fromCurrency),
                              ),

                              const SizedBox(height: 12),

                              AnimatedRotation(
                                turns: isSwapped ? 0.5 : 0,
                                duration: const Duration(milliseconds: 400),
                                child: GestureDetector(
                                  onTap: swapCurrencies,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.swap_vert,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              _currencyCard(toCurrency),

                              const SizedBox(height: 12),

                              TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  prefixIcon: const Icon(
                                    Icons.monetization_on_outlined,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: border,
                                  focusedBorder: border,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        ValueListenableBuilder<LearningMode>(
                          valueListenable: LearningModeController.currentMode,
                          builder: (context, mode, _) {
                            return Column(
                              children: [
                                Text(
                                  '${result.toStringAsFixed(2)} $toCurrency',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                if (mode == LearningMode.student ||
                                    mode == LearningMode.finance)
                                  TextButton(
                                    onPressed: showCalculationHelp,
                                    child: const Text(
                                      'How is this calculated?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                if (mode == LearningMode.finance)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Insight: Exchange rates fluctuate due to market demand and global factors.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExchangeRateInsightScreen(
                          volatility: lastVolatility!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currencyCard(String currency) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

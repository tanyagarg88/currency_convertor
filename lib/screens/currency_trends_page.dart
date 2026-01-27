import 'package:currency_convertor/models/exchange_rate_model.dart';
import 'package:currency_convertor/services/exchange_rate_graph.dart';
import 'package:flutter/material.dart';
import '../services/currency_api_service.dart';

class CurrencyTrendsPage extends StatefulWidget {
  const CurrencyTrendsPage({super.key});

  @override
  State<CurrencyTrendsPage> createState() => _CurrencyTrendsPageState();
}

class _CurrencyTrendsPageState extends State<CurrencyTrendsPage> {
  bool isLoading = true;

  List<ExchangeRate> usdTrend = [];
  List<ExchangeRate> eurTrend = [];
  List<ExchangeRate> inrTrend = [];

  @override
  void initState() {
    super.initState();
    loadTrendData();
  }

  Future<void> loadTrendData() async {
    try {
      usdTrend = await CurrencyApiService.getHistoricalRates('USD', 'INR');
      eurTrend = await CurrencyApiService.getHistoricalRates('EUR', 'INR');
      inrTrend = await CurrencyApiService.getHistoricalRates('INR', 'USD');
    } catch (_) {}

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Currency Trends',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _trendCard(
                              title: 'USD Trend',
                              color: Colors.blue,
                              rates: usdTrend,
                            ),
                            const SizedBox(height: 16),

                            _trendCard(
                              title: 'EUR Trend',
                              color: Colors.orange,
                              rates: eurTrend,
                            ),
                            const SizedBox(height: 16),

                            _trendCard(
                              title: 'INR Trend',
                              color: Colors.green,
                              rates: inrTrend,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trendCard({
    required String title,
    required Color color,
    required List<ExchangeRate> rates,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ExchangeRateGraph(rates: rates.map((e) => e.rate).toList()),
          ),

          const SizedBox(height: 8),
          const Text(
            'Last 7 days trend',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

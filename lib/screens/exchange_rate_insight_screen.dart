import 'package:flutter/material.dart';
import '../models/volatility_result.dart';
import '../learning/learning_mode_controller.dart';
import '../theme/app_gradient.dart';

class ExchangeRateInsightScreen extends StatelessWidget {
  final VolatilityResult? volatility;

  const ExchangeRateInsightScreen({super.key, this.volatility});

  List<Map<String, String>> _getInsightsForMode(LearningMode mode) {
    switch (mode) {
      case LearningMode.beginner:
        return [
          {
            'title': 'Market Demand',
            'desc': 'When more people want a currency, its value increases.',
          },
          {
            'title': 'Inflation',
            'desc': 'High inflation reduces the value of a country’s money.',
          },
        ];

      case LearningMode.student:
        return [
          {
            'title': 'Market Demand',
            'desc':
                'Exchange rates fluctuate based on demand and supply in global markets.',
          },
          {
            'title': 'Interest Rates',
            'desc':
                'Higher interest rates attract foreign investment, strengthening currency.',
          },
        ];

      case LearningMode.finance:
        return [
          {
            'title': 'Monetary Policy',
            'desc':
                'Central bank policies influence currency value through interest rates and liquidity.',
          },
          {
            'title': 'Global Events',
            'desc':
                'Geopolitical and macroeconomic events can cause sharp currency volatility.',
          },
        ];
    }
  }

  String _volatilitySummary(LearningMode mode) {
    if (volatility != null && volatility!.percentChange.abs() < 0.05) {
      Text(
        'No significant market movement detected.',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    if (mode == LearningMode.beginner) {
      return volatility!.isIncrease
          ? 'The currency became stronger recently.'
          : 'The currency became weaker recently.';
    }

    if (mode == LearningMode.student) {
      return volatility!.isIncrease
          ? 'Recent demand or economic signals increased the exchange rate.'
          : 'Recent uncertainty or reduced demand lowered the exchange rate.';
    }

    return volatility!.isIncrease
        ? 'Appreciation suggests capital inflows or interest rate optimism.'
        : 'Depreciation suggests risk-off sentiment or macro pressure.';
  }

  @override
  Widget build(BuildContext context) {
    final LearningMode mode = LearningModeController.currentMode.value;
    final insights = _getInsightsForMode(mode);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Exchange Rate Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.mainGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (volatility != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      volatility!.isIncrease
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: volatility!.isIncrease
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${volatility!.percentChange.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _volatilitySummary(mode),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            const Text(
              'Why exchange rates change',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            ...insights.map(
              (item) => _InsightCard(
                icon: Icons.lightbulb_outline,
                title: item['title']!,
                description: item['desc']!,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Insights adapt based on your learning mode.',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

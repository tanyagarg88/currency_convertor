import 'package:flutter/material.dart';
import '../theme/app_gradient.dart';
import '../learning/learning_mode_controller.dart';

class ExchangeRateInsightScreen extends StatelessWidget {
  const ExchangeRateInsightScreen({super.key});

  // 🔹 Dynamic content based on learning mode
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

  @override
  Widget build(BuildContext context) {
    final LearningMode mode = LearningModeController.currentMode.value;
    final List<Map<String, String>> insights = _getInsightsForMode(mode);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Why Exchange Rates Change'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.mainGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),

            const Text(
              'Exchange rates change due to economic and global factors. '
              'Here are the key reasons explained based on your learning level:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 16),

            // 🔹 Dynamic cards
            ...insights.map(
              (item) => _InsightCard(
                icon: Icons.lightbulb_outline,
                title: item['title']!,
                description: item['desc']!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Reusable card widget
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

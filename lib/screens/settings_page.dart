import 'package:flutter/material.dart';
import '../learning/learning_mode_controller.dart';
import '../theme/app_gradient.dart';
import 'exchange_rate_insight_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.mainGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            const Text(
              'Learning Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            ValueListenableBuilder<LearningMode>(
              valueListenable: LearningModeController.currentMode,
              builder: (context, mode, _) {
                return DropdownButtonFormField<LearningMode>(
                  initialValue: mode,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: LearningMode.beginner,
                      child: Text('Beginner – Simple conversion'),
                    ),
                    DropdownMenuItem(
                      value: LearningMode.student,
                      child: Text('Student – Formula & explanation'),
                    ),
                    DropdownMenuItem(
                      value: LearningMode.finance,
                      child: Text('Finance – Trends & insights'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      LearningModeController.currentMode.value = value;
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            const Text(
              'The app adapts its explanations and insights based on your selected level.',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),

            const SizedBox(height: 28),
            const Text(
              'Learning & Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.deepPurple,
                ),
                title: const Text(
                  'Why exchange rates change',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Understand the factors behind currency fluctuations',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExchangeRateInsightScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

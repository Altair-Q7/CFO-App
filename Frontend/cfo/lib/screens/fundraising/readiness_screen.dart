import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(fundraisingReadinessProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Fundraising Readiness')),
      body: readinessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (readiness) {
          if (readiness == null) return const Center(child: Text('No data available'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _scoreCard('Overall Score', readiness.overallScore, Colors.blue),
                _scoreCard('Financial Health', readiness.financialHealth, Colors.green),
                const SizedBox(height: 24),
                const Text('Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (readiness.breakdown != null)
                  ...readiness.breakdown!.entries.map((e) => ListTile(
                    title: Text(e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
                    trailing: Text('${e.value.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
                const SizedBox(height: 16),
                const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (readiness.details != null)
                  ...readiness.details!.entries.map((e) => ListTile(
                    title: Text(e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
                    trailing: Text('\$${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _scoreCard(String label, int score, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text('$score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: score / 100, backgroundColor: Colors.grey[200], color: color),
        ]),
      ),
    );
  }
}
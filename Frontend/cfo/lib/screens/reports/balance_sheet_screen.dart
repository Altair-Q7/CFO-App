import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class BalanceSheetScreen extends ConsumerWidget {
  const BalanceSheetScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balance Sheet')),
      body: FutureBuilder(
        future: ref.read(reportsServiceProvider).getReport('balance-sheet'),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final data = snap.data!.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Assets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['assets'] as List? ?? []).map((a) => ListTile(title: Text(a['name']), trailing: Text('\$${a['value'].toStringAsFixed(0)}'))),
              _boldRow('Total Assets', '\$${(data['totalAssets'] ?? 0).toStringAsFixed(0)}'),
              const Divider(),
              const Text('Liabilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['liabilities'] as List? ?? []).map((l) => ListTile(title: Text(l['name']), trailing: Text('\$${l['value'].toStringAsFixed(0)}'))),
              _boldRow('Total Liabilities', '\$${(data['totalLiabilities'] ?? 0).toStringAsFixed(0)}'),
              const Divider(),
              const Text('Equity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['equity'] as List? ?? []).map((e) => ListTile(title: Text(e['name']), trailing: Text('\$${e['value'].toStringAsFixed(0)}'))),
              _boldRow('Total Equity', '\$${(data['totalEquity'] ?? 0).toStringAsFixed(0)}'),
            ],
          );
        },
      ),
    );
  }

  Widget _boldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }
}
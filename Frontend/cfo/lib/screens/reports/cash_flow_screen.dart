import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class CashFlowScreen extends ConsumerWidget {
  const CashFlowScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Flow Statement')),
      body: FutureBuilder(
        future: ref.read(reportsServiceProvider).getReport('cash-flow'),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final data = snap.data!.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Operating Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['operating'] as List? ?? []).map((o) => ListTile(title: Text(o['description']), trailing: Text('\$${o['value'].toStringAsFixed(0)}'))),
              _boldRow('Net Operating', '\$${(data['netOperating'] ?? 0).toStringAsFixed(0)}'),
              const Divider(),
              const Text('Investing Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['investing'] as List? ?? []).map((i) => ListTile(title: Text(i['description']), trailing: Text('\$${i['value'].toStringAsFixed(0)}'))),
              _boldRow('Net Investing', '\$${(data['netInvesting'] ?? 0).toStringAsFixed(0)}'),
              const Divider(),
              const Text('Financing Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...(data['financing'] as List? ?? []).map((f) => ListTile(title: Text(f['description']), trailing: Text('\$${f['value'].toStringAsFixed(0)}'))),
              _boldRow('Net Financing', '\$${(data['netFinancing'] ?? 0).toStringAsFixed(0)}'),
              const Divider(),
              _boldRow('Net Cash Change', '\$${(data['netCashChange'] ?? 0).toStringAsFixed(0)}'),
              _boldRow('Beginning Cash', '\$${(data['beginningCash'] ?? 0).toStringAsFixed(0)}'),
              _boldRow('Ending Cash', '\$${(data['endingCash'] ?? 0).toStringAsFixed(0)}'),
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
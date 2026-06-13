import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class PnlReportScreen extends ConsumerWidget {
  const PnlReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profit & Loss')),
      body: FutureBuilder(
        future: ref.read(reportsServiceProvider).getReport('pnl'),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final report = snap.data!;
          final data = report.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _row('Total Revenue', '\$${(data['totalRevenue'] ?? 0).toStringAsFixed(0)}'),
              _row('Cost of Goods Sold', '\$${(data['cogs'] ?? 0).toStringAsFixed(0)}'),
              _row('Gross Profit', '\$${(data['grossProfit'] ?? 0).toStringAsFixed(0)}'),
              _row('Total Expenses', '\$${(data['totalExpenses'] ?? 0).toStringAsFixed(0)}'),
              _row('Net Profit', '\$${(data['netProfit'] ?? 0).toStringAsFixed(0)}', bold: true),
              const Divider(),
              _row('Revenue Growth', '${data['revenueGrowth'] ?? 0}%'),
              _row('Profit Margin', '${data['profitMargin'] ?? 0}%'),
              _row('Operating Ratio', '${data['operatingRatio'] ?? 0}%'),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportCard(context, 'Profit & Loss Statement', 'View revenue, expenses, and net profit', Icons.assessment, '/reports/pnl'),
          _reportCard(context, 'Balance Sheet', 'Assets, liabilities, and equity overview', Icons.account_balance, '/reports/balance-sheet'),
          _reportCard(context, 'Cash Flow Statement', 'Operating, investing, and financing activities', Icons.cash, '/reports/cash-flow'),
        ],
      ),
    );
  }

  Widget _reportCard(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: const Color(0xFF0B1F3A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
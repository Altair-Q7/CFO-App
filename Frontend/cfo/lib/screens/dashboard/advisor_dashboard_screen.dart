import 'package:flutter/material.dart';

class AdvisorDashboardScreen extends StatelessWidget {
  const AdvisorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advisor Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Client Portfolio', 'Manage your clients', Icons.business_center, () {}),
          _card('Consultation Schedule', 'View upcoming sessions', Icons.calendar_today, () {}),
          _card('Revenue Tracking', 'Track consulting revenue', Icons.attach_money, () {}),
          _card('Client Onboarding', 'New client setup', Icons.person_add, () {}),
        ],
      ),
    );
  }

  Widget _card(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: const Color(0xFF0B1F3A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
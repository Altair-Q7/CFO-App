import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Manage Advisors', 'Verify and manage advisor accounts', Icons.verified_user, () {}),
          _card('Platform Analytics', 'View system-wide metrics', Icons.analytics, () {}),
          _card('Subscription Management', 'Manage billing and subscriptions', Icons.subscriptions, () {}),
          _card('User Management', 'View and manage users', Icons.people, () {}),
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
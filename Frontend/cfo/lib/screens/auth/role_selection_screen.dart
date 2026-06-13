import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = [
      {'role': 'founder', 'icon': Icons.business, 'title': 'Founder', 'desc': 'Access your financial dashboard, forecasts, and AI assistant'},
      {'role': 'advisor', 'icon': Icons.analytics, 'title': 'Advisor', 'desc': 'Manage client portfolios and consulting sessions'},
      {'role': 'admin', 'icon': Icons.admin_panel_settings, 'title': 'Admin', 'desc': 'Manage platform, verify advisors, and system analytics'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Choose your role to continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...roles.map((r) => Card(
              child: ListTile(
                leading: Icon(r['icon'] as IconData, size: 40, color: const Color(0xFF0B1F3A)),
                title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(r['desc'] as String),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ref.read(authProvider.notifier).setRole(r['role'] as String);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
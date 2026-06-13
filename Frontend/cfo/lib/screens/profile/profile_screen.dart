import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final user = data['user'] is Map ? data['user'] as Map<String, dynamic> : {};
          final company = data['company'] is Map ? data['company'] as Map<String, dynamic> : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
              const SizedBox(height: 16),
              Center(child: Text(user['name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              Center(child: Text(user['email'] ?? '', style: const TextStyle(color: Colors.grey))),
              Center(child: Chip(label: Text(auth.role.toUpperCase()))),
              const SizedBox(height: 24),
              const Text('Company Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (company != null) ...[
                _infoTile('Company Name', company['name'] ?? 'N/A'),
                _infoTile('Industry', company['industry'] ?? 'N/A'),
                _infoTile('Monthly Revenue', '\$${(company['monthly_revenue'] ?? 0).toStringAsFixed(0)}'),
                _infoTile('Monthly Expenses', '\$${(company['monthly_expenses'] ?? 0).toStringAsFixed(0)}'),
                _infoTile('Employees', '${company['employees'] ?? 0}'),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
                  child: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
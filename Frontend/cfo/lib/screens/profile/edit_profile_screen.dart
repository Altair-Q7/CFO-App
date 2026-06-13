import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  final _expensesCtrl = TextEditingController();
  final _employeesCtrl = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final user = data['user'] is Map ? data['user'] as Map<String, dynamic> : {};
          final company = data['company'] is Map ? data['company'] as Map<String, dynamic> : null;
          if (!_initialized) {
            _nameCtrl.text = user['name'] ?? '';
            _companyNameCtrl.text = company?['name'] ?? '';
            _industryCtrl.text = company?['industry'] ?? '';
            _revenueCtrl.text = company?['monthly_revenue']?.toString() ?? '';
            _expensesCtrl.text = company?['monthly_expenses']?.toString() ?? '';
            _employeesCtrl.text = company?['employees']?.toString() ?? '';
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _companyNameCtrl, decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _industryCtrl, decoration: const InputDecoration(labelText: 'Industry', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _revenueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Revenue (\$)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _expensesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Expenses (\$)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _employeesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Employees', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1F3A), foregroundColor: Colors.white),
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(profileServiceProvider).updateProfile(
        name: _nameCtrl.text,
        companyName: _companyNameCtrl.text,
        industry: _industryCtrl.text,
        monthlyRevenue: double.tryParse(_revenueCtrl.text),
        monthlyExpenses: double.tryParse(_expensesCtrl.text),
        employees: int.tryParse(_employeesCtrl.text),
      );
      ref.invalidate(profileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }
}
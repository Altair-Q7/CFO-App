import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _companyCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  final _expensesCtrl = TextEditingController();
  final _employeesCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).onboarding(
        companyName: _companyCtrl.text,
        industry: _industryCtrl.text,
        monthlyRevenue: double.tryParse(_revenueCtrl.text) ?? 0,
        monthlyExpenses: double.tryParse(_expensesCtrl.text) ?? 0,
        employees: int.tryParse(_employeesCtrl.text) ?? 0,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Setup')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Tell us about your company', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: _companyCtrl, decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _industryCtrl, decoration: const InputDecoration(labelText: 'Industry', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _revenueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Revenue (\$)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _expensesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Expenses (\$)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _employeesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Employees', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1F3A), foregroundColor: Colors.white),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
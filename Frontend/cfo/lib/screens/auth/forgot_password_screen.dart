import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _message;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() { _loading = true; _message = null; });
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.post(ApiConstants.forgotPassword, body: {'email': _emailCtrl.text}, auth: false);
      setState(() { _message = data['message'] ?? 'Check your email'; });
    } catch (e) {
      setState(() { _message = 'Error: $e'; });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.lock_reset, size: 64, color: Color(0xFF0B1F3A)),
              const SizedBox(height: 16),
              const Text('Enter your email to reset your password', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              if (_message != null) Text(_message!, style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const CircularProgressIndicator() : const Text('Send Reset Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
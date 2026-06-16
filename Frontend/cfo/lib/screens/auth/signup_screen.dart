import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _signup() async {
    setState(() { _loading = true; _error = null; });
    final error = await ref.read(authProvider.notifier).signup(_nameCtrl.text, _emailCtrl.text, _passCtrl.text, 'founder');
    if (!mounted) return;
    setState(() { _loading = false; });
    if (error != null) {
      setState(() { _error = error; });
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {required bool isDark}) {
    final fillCol = isDark ? AppTheme.darkElevated : AppTheme.lightElevated;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final labelCol = isDark ? AppTheme.textOnDarkMuted : AppTheme.onSurfaceTextSecondary(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: labelCol, fontSize: 14),
      prefixIcon: Icon(icon, color: labelCol, size: 20),
      filled: true,
      fillColor: fillCol,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderCol),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final bg = isDark ? AppTheme.darkBase : AppTheme.lightBase;
    final textPrimary = isDark ? AppTheme.textOnDark : AppTheme.onSurfaceText(context);
    final textSecondary = isDark ? AppTheme.textOnDarkMuted : AppTheme.onSurfaceTextSecondary(context);
    final cardBg = isDark ? AppTheme.darkElevated : AppTheme.lightSurface;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        foregroundColor: isDark ? AppTheme.textOnDark : AppTheme.onSurfaceText(context),
        elevation: 0,
        centerTitle: true,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 64, color: AppTheme.iconOnSurface(context)),
                    const SizedBox(height: 16),
                    Text('Create your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary)),
                    const SizedBox(height: 8),
                    Text('Fill in the details to get started', style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameCtrl,
                      style: TextStyle(color: textPrimary),
                      decoration: _inputDecoration('Full Name', Icons.person_outlined, isDark: isDark),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textPrimary),
                      decoration: _inputDecoration('Email', Icons.email_outlined, isDark: isDark),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      style: TextStyle(color: textPrimary),
                      decoration: _inputDecoration('Password', Icons.lock_outlined, isDark: isDark),
                    ),
                    const SizedBox(height: 8),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.coral.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.coral, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!, style: const TextStyle(
                                color: AppTheme.coral, fontSize: 13,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navyMid,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

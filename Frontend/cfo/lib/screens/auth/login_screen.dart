import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../widgets/madi_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;
  String? _error;

  final List<Map<String, String>> _demoLogins = [
    {
      'role': 'Founder',
      'name': 'Alex Rivera',
      'email': 'alex@startup.co',
      'password': 'demo123',
      'company': 'TechFlow Inc.',
      'roleKey': 'founder',
      'borderColor': 'emerald',
    },
    {
      'role': 'Advisor',
      'name': 'Sarah Chen',
      'email': 'sarah@advisor.co',
      'password': 'demo123',
      'company': 'CFO Advisory',
      'roleKey': 'advisor',
      'borderColor': 'amber',
    },
    {
      'role': 'Admin',
      'name': 'Admin User',
      'email': 'admin@scalable.co',
      'password': 'demo123',
      'company': 'The Scalable CFO',
      'roleKey': 'admin',
      'borderColor': 'gold',
    },
  ];

  Color _borderColor(String key) {
    switch (key) {
      case 'emerald':
        return AppTheme.emerald;
      case 'amber':
        return AppTheme.amber;
      default:
        return AppTheme.gold;
    }
  }

  void _quickLogin(Map<String, String> account) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    await ref.read(authProvider.notifier).demoLogin(
          name: account['name']!,
          email: account['email']!,
          role: account['roleKey']!,
        );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final match = _demoLogins.firstWhere(
      (a) => a['email'] == _emailCtrl.text.trim(),
      orElse: () => {},
    );

    if (match.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No demo account found for that email';
      });
      return;
    }

    await ref.read(authProvider.notifier).demoLogin(
          name: match['name']!,
          email: match['email']!,
          role: match['roleKey']!,
        );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/home');
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
    final cardBg = isDark ? AppTheme.darkElevated : AppTheme.lightSurface;
    final textPrimary = isDark ? AppTheme.textOnDark : AppTheme.onSurfaceText(context);
    final textSecondary = isDark ? AppTheme.textOnDarkMuted : AppTheme.onSurfaceTextSecondary(context);
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Theme toggle — top right
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: textSecondary,
                    ),
                    tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
                    onPressed: () {
                      ref.read(themeProvider.notifier).setTheme(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // MADI branding block
              Center(
                child: Column(
                  children: [
                    const MadiLogo(size: 68),
                    const SizedBox(height: 16),
                    const Text('MADI', style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                    )),
                    const SizedBox(height: 6),
                    Text('Financial Operations Center', style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    )),
                    const SizedBox(height: 4),
                    Text('by The Scalable CFO', style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Demo access section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DEMO ACCESS', style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    )),
                    const SizedBox(height: 12),
                    ..._demoLogins.map((account) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(
                          left: BorderSide(
                            color: _borderColor(account['borderColor']!),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _loading ? null : () => _quickLogin(account),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(account['role']!, style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      )),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${account['name']} \u00B7 ${account['company']}',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_loading)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: textSecondary,
                                    ),
                                  )
                                else
                                  Text('Enter \u2192', style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: Container(
                      height: 1, color: borderCol,
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or continue with credentials', style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      )),
                    ),
                    Expanded(child: Container(
                      height: 1, color: borderCol,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Manual login form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    if (_error != null) ...[
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
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textPrimary),
                      decoration: _inputDecoration('Email', Icons.email_outlined, isDark: isDark),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      style: TextStyle(color: textPrimary),
                      decoration: _inputDecoration('Password', Icons.lock_outlined, isDark: isDark).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
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
                            : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Footer
              Text('Powered by MADI Intelligence', style: TextStyle(
                color: textSecondary,
                fontSize: 11,
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

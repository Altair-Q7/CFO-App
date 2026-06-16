// =============================================================================
// SplashScreen — MADI Financial Operations Center Launch Screen
// =============================================================================
// Displays the MADI branding with gold "M" logo, navy gradient background,
// and animated pulse effect. Checks backend availability before navigating
// to login. This is the first impression of the app.
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../providers/providers.dart';
import '../services/backend_service.dart';
import '../widgets/madi_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initApp();
    // Animated pulse for the MADI logo glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Checks backend health, starts monitoring, then navigates to login
  Future<void> _initApp() async {
    final available = await BackendChecker.check();
    if (!mounted) return;
    ref.read(backendAvailableProvider.notifier).state = available;
    BackendMonitor.start(ProviderScope.containerOf(context));

    if (!mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.navyGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MADI Logo with animated gold glow
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold
                          .withValues(alpha: 0.4 * _pulseAnimation.value),
                      blurRadius: 30 * _pulseAnimation.value,
                      spreadRadius: 5 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: const MadiLogo(size: 110),
              ),
            ),
            const SizedBox(height: 32),
            // App title
            const Text(
              'The Scalable CFO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Powered by MADI Intelligence',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.gold.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

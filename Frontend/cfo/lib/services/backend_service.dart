import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../core/constants/api_constants.dart';
import '../providers/providers.dart';

// Stateless ping — no ref held, safe to call from anywhere
class BackendChecker {
  static Future<bool> check() async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/health',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// Uses a ProviderContainer — not tied to any widget lifecycle
class BackendMonitor {
  static Timer? _timer;
  static ProviderContainer? _container;

  static void start(ProviderContainer container) {
    _container = container;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _check() async {
    if (_container == null) return;
    final available = await BackendChecker.check();
    _container!.read(backendAvailableProvider.notifier).state = available;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../core/constants/api_constants.dart';
import '../providers/providers.dart';

// Periodically checks if backend is reachable.
// Call BackendMonitor.start(ref) once from main() or splash screen.
class BackendMonitor {
  static Timer? _timer;

  static Future<void> start(WidgetRef ref) async {
    await _check(ref);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check(ref));
  }

  static Future<void> _check(WidgetRef ref) async {
    final available = await _ping();
    ref.read(backendAvailableProvider.notifier).state = available;
  }

  static Future<bool> _ping() async {
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

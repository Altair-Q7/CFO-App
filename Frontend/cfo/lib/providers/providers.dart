import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/forecast_service.dart';
import '../services/ai_service.dart';
import '../services/reports_service.dart';
import '../services/marketplace_service.dart';
import '../services/fundraising_service.dart';
import '../services/notifications_service.dart';
import '../services/profile_service.dart';
import '../models/user.dart';
import '../models/dashboard_metrics.dart';
import '../models/financial_data.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../models/advisor_model.dart';
import '../models/chat_message.dart';
import '../models/forecast_result.dart';
import '../models/report_data.dart';

// --- Token Storage (singleton) ---
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

// --- API Client ---
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(tokenStorageProvider));
});

// --- Services ---
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider), ref.read(tokenStorageProvider));
});
final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService(ref.read(apiClientProvider)));
final forecastServiceProvider = Provider<ForecastService>((ref) => ForecastService(ref.read(apiClientProvider)));
final aiServiceProvider = Provider<AiService>((ref) => AiService(ref.read(apiClientProvider)));
final reportsServiceProvider = Provider<ReportsService>((ref) => ReportsService(ref.read(apiClientProvider)));
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) => MarketplaceService(ref.read(apiClientProvider)));
final fundraisingServiceProvider = Provider<FundraisingService>((ref) => FundraisingService(ref.read(apiClientProvider)));
final notificationsServiceProvider = Provider<NotificationsService>((ref) => NotificationsService(ref.read(apiClientProvider)));
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService(ref.read(apiClientProvider)));

// --- Auth State ---
class AuthState {
  final bool isLoggedIn;
  final String? token;
  final String role;
  final String? userId;
  final String? name;
  final String? email;
  final bool isLoading;

  AuthState({this.isLoggedIn = false, this.token, this.role = 'founder', this.userId, this.name, this.email, this.isLoading = false});

  AuthState copyWith({bool? isLoggedIn, String? token, String? role, String? userId, String? name, String? email, bool? isLoading}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(AuthState());

  Future<void> init() async {
    final token = _authService.getStoredToken();
    if (token != null) {
      final role = _authService.getStoredRole() ?? 'founder';
      state = AuthState(isLoggedIn: true, token: token, role: role);
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _authService.login(email, password);
      final user = data['user'];
      state = AuthState(isLoggedIn: true, token: data['token'], role: user['role'] ?? 'founder', userId: user['id'], name: user['name'], email: user['email']);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString();
    }
  }

  Future<String?> signup(String name, String email, String password, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _authService.signup(name, email, password, role);
      final user = data['user'];
      state = AuthState(isLoggedIn: true, token: data['token'], role: user['role'] ?? role, userId: user['id'], name: user['name'], email: user['email']);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void setRole(String role) {
    state = state.copyWith(role: role);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// --- Dashboard State ---
final dashboardMetricsProvider = FutureProvider<DashboardMetrics?>((ref) async {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;
  if (!isLoggedIn) return null;
  try {
    return await ref.read(dashboardServiceProvider).getMetrics();
  } catch (e) {
    return null;
  }
});

final dashboardTrendsProvider = FutureProvider<List<FinancialData>>((ref) async {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;
  if (!isLoggedIn) return [];
  try {
    return await ref.read(dashboardServiceProvider).getTrends();
  } catch (e) {
    return [];
  }
});

final dashboardActivityProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;
  if (!isLoggedIn) return {};
  try {
    return await ref.read(dashboardServiceProvider).getActivity();
  } catch (e) {
    return {};
  }
});

// --- Forecast State ---
final forecastProvider = StateNotifierProvider<ForecastNotifier, AsyncValue<ForecastResult?>>((ref) {
  return ForecastNotifier(ref.read(forecastServiceProvider));
});

class ForecastNotifier extends StateNotifier<AsyncValue<ForecastResult?>> {
  final ForecastService _service;
  ForecastNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> load({int months = 12, double revenueGrowth = 5, double expenseGrowth = 3, double hiringCost = 0}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.getProjection(months: months, revenueGrowth: revenueGrowth, expenseGrowth: expenseGrowth, hiringCost: hiringCost);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- AI Chat State ---
final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<ChatMessage>>((ref) {
  return AiChatNotifier(ref.read(aiServiceProvider));
});

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AiService _service;
  AiChatNotifier(this._service) : super([]);

  Future<void> loadHistory() async {
    try {
      final history = await _service.getHistory();
      state = history;
    } catch (_) {}
  }

  Future<List<String>> send(String message) async {
    state = [...state, ChatMessage(role: 'user', content: message)];
    try {
      final result = await _service.chat(message);
      state = [...state, ChatMessage(role: 'assistant', content: result['response'])];
      return List<String>.from(result['suggestedQuestions'] ?? []);
    } catch (e) {
      state = [...state, ChatMessage(role: 'assistant', content: 'Error: $e')];
      return [];
    }
  }
}

// --- Notifications State ---
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return NotificationsNotifier(ref.read(notificationsServiceProvider));
});

class NotificationsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final NotificationsService _service;
  NotificationsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> load() async {
    try {
      final data = await _service.getNotifications();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead(String id) async {
    await _service.markAsRead(id);
    await load();
  }

  Future<void> markAllRead() async {
    await _service.markAllAsRead();
    await load();
  }
}

// --- Marketplace ---
final advisorsProvider = FutureProvider<List<AdvisorModel>>((ref) async {
  return await ref.read(marketplaceServiceProvider).getAdvisors();
});

// --- Fundraising ---
final fundraisingReadinessProvider = FutureProvider<FundraisingReadiness?>((ref) async {
  try {
    return await ref.read(fundraisingServiceProvider).getReadiness();
  } catch (_) {
    return null;
  }
});

final dataRoomProvider = FutureProvider<List<DataRoomFile>>((ref) async {
  try {
    return await ref.read(fundraisingServiceProvider).getDataRoom();
  } catch (_) {
    return [];
  }
});

// --- Profile ---
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    return await ref.read(profileServiceProvider).getProfile();
  } catch (_) {
    return {};
  }
});
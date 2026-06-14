# Implementation Guide — The Scalable CFO
> Written by Claude for DeepSeek Code V3 Flash to execute.
> Read every section before writing a single line of code.
> Execute in order. Do not skip steps.

---

## What you are building

A Flutter + Node.js fintech SaaS app called "The Scalable CFO".
Three user roles: **founder**, **advisor**, **admin**.

Your job in this session:
1. Add graceful backend fallback (try backend → fall back to mock if offline)
2. Fix the main shell so all three roles get proper navigation + logout
3. Make the admin dashboard tell a real platform story

---

## Project structure (what exists)

```
CFO App/
├── Backend/                         ← Node.js + Express + SQLite
│   ├── server.js                    ← entry point, port 3001
│   ├── src/
│   │   ├── database/
│   │   │   ├── connection.js        ← better-sqlite3 setup
│   │   │   └── seed.js              ← seeds 6 advisors on first run
│   │   ├── middleware/
│   │   │   └── auth.js              ← JWT middleware, authenticate()
│   │   ├── routes/
│   │   │   ├── auth.js              ← /signup /login /forgot-password /onboarding
│   │   │   ├── dashboard.js         ← /metrics /trends /activity
│   │   │   ├── aiAssistant.js       ← /chat /history /suggestions
│   │   │   ├── forecasting.js       ← /project
│   │   │   ├── reports.js           ← /pnl /balance-sheet /cash-flow
│   │   │   ├── marketplace.js       ← /advisors /advisors/:id /book
│   │   │   ├── fundraising.js       ← /readiness /data-room
│   │   │   ├── notifications.js     ← GET/ PATCH/:id/read POST/mark-all-read
│   │   │   └── profile.js           ← GET/ PATCH/
│   │   └── services/
│   │       ├── aiResponses.js       ← keyword-based mock AI responses
│   │       ├── forecastingEngine.js ← runway calculation
│   │       ├── mockDataGenerator.js ← generates per-company financial data
│   │       └── pdfGenerator.js      ← PDF reports
│   └── package.json                 ← better-sqlite3, express, jwt, bcrypt, uuid
│
└── Frontend/cfo/
    └── lib/
        ├── main.dart                ← app entry point
        ├── app.dart                 ← MaterialApp + all routes
        ├── core/
        │   ├── constants/
        │   │   ├── app_constants.dart    ← demoMode flag, AppTheme
        │   │   └── api_constants.dart    ← all backend URLs
        │   ├── network/
        │   │   ├── api_client.dart       ← HTTP wrapper (get/post/patch/put)
        │   │   └── api_exception.dart    ← ApiException class
        │   └── storage/
        │       └── token_storage.dart    ← SharedPreferences wrapper
        ├── models/                       ← data classes (do not modify)
        ├── providers/
        │   └── providers.dart            ← ALL Riverpod state (read carefully)
        ├── screens/
        │   ├── auth/
        │   │   └── login_screen.dart     ← currently broken (see BUGS)
        │   ├── dashboard/
        │   │   ├── founder_dashboard_screen.dart
        │   │   ├── advisor_dashboard_screen.dart   ← single page, no nav
        │   │   └── admin_dashboard_screen.dart     ← single page, no nav
        │   ├── main_shell_screen.dart    ← founder-only shell, needs role awareness
        │   └── [other screens]
        └── services/
            ├── mock_data_service.dart    ← singleton, all hardcoded mock data
            ├── auth_service.dart         ← calls /auth/* endpoints
            └── [other services]          ← each calls ApiClient
```

---

## Current bugs (fix these, in order)

### BUG-001 — TokenStorage never initialized
**File:** `lib/main.dart`
**Problem:** `TokenStorage._cachedToken` is null on cold start because `loadCachedData()` is never called before `runApp()`.
**Fix:** See Task 1 below.

### BUG-002 — saveUserData saves garbage
**File:** `lib/core/storage/token_storage.dart`
**Problem:** `prefs.setString(AppConstants.userKey, user.toString())` — `Map.toString()` is not JSON.
**Fix:** Replace with `jsonEncode(user)`. Add `import 'dart:convert';` at top if missing.

### BUG-003 — Login bypasses Riverpod entirely
**File:** `lib/screens/auth/login_screen.dart`
**Problem:** `_login()` just delays 800ms and navigates. Never calls `authProvider.notifier`. Role stored in static `LoginRoleStorage.currentRole`, not in state.
**Fix:** See Task 3 below.

### BUG-004 — No graceful backend fallback
**Problem:** `demoMode = true` hardcoded. App never tries backend. If you set it to false and backend is offline, app crashes.
**Fix:** See Task 2 below.

### BUG-005 — Shell is founder-only
**File:** `lib/screens/main_shell_screen.dart`
**Problem:** Admin and advisor dashboards render without a shell — no bottom nav, no logout.
**Fix:** See Task 4 below.

---

## Task 1 — Fix main.dart

**File to modify:** `lib/main.dart`

**Replace entire file with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/token_storage.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // BUG-001 FIX: initialize token storage before runApp
  final tokenStorage = TokenStorage();
  await tokenStorage.loadCachedData();

  runApp(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
      child: const CfoApp(),
    ),
  );
}
```

---

## Task 2 — Add graceful backend fallback

This is the core of this session. The pattern:
- On app start, ping `GET /api/health`
- If it responds → `backendAvailable = true`, use real API calls
- If it fails/times out → `backendAvailable = false`, use MockDataService
- Re-check every 30 seconds silently in background

### Step 2a — Add backend status provider to `providers.dart`

**File:** `lib/providers/providers.dart`

Add this BEFORE the existing `// --- Auth State ---` section:

```dart
// --- Backend Availability ---
// Pings /health on startup and every 30s. All services check this before calling API.
final backendAvailableProvider = StateProvider<bool>((ref) => false);

class BackendChecker {
  static Future<bool> check() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl.replaceAll('/api', '')}/api/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
```

Add this import at the top of `providers.dart` if not already present:
```dart
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
```

### Step 2b — Create `lib/services/backend_service.dart` (new file)

```dart
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
```

### Step 2c — Update `lib/screens/splash_screen.dart`

Find the splash screen's `initState` or `build` method. Add the backend check before navigating away.

Find where it calls `Navigator.pushReplacementNamed` and add before it:

```dart
// Check backend availability before navigating
final available = await BackendChecker.check();
ref.read(backendAvailableProvider.notifier).state = available;
```

Make the splash screen a `ConsumerStatefulWidget` if it isn't already. Import:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/backend_service.dart';
```

### Step 2d — Update each service to use fallback

For EVERY service in `lib/services/` (dashboard_service.dart, forecast_service.dart, ai_service.dart, reports_service.dart, marketplace_service.dart, fundraising_service.dart, notifications_service.dart, profile_service.dart):

**Pattern to follow — example for `dashboard_service.dart`:**

```dart
import '../services/mock_data_service.dart';

class DashboardService {
  final ApiClient _client;
  final bool _useMock; // injected from provider

  DashboardService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<DashboardMetrics?> getMetrics() async {
    if (_useMock) {
      // artificial delay so it feels like a real call
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService().getMockMetrics();
    }
    try {
      final data = await _client.get(ApiConstants.dashboardMetrics);
      return DashboardMetrics.fromJson(data);
    } catch (_) {
      // backend failed mid-session, fall back gracefully
      return MockDataService().getMockMetrics();
    }
  }

  Future<List<FinancialData>> getTrends() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockTrends();
    }
    try {
      final data = await _client.get(ApiConstants.dashboardTrends);
      final trends = data['trends'] as List? ?? [];
      return trends.map((e) => FinancialData.fromJson(e)).toList();
    } catch (_) {
      return MockDataService().getMockTrends();
    }
  }

  Future<Map<String, dynamic>> getActivity() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockActivity();
    }
    try {
      return await _client.get(ApiConstants.dashboardActivity);
    } catch (_) {
      return MockDataService().getMockActivity();
    }
  }
}
```

Apply the same pattern to every other service — `_useMock` flag, try real call, catch → return mock.

### Step 2e — Update service providers in `providers.dart`

Find the `dashboardServiceProvider` and update it to pass `useMock` based on backend availability:

```dart
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final useMock = !ref.watch(backendAvailableProvider);
  return DashboardService(ref.read(apiClientProvider), useMock: useMock);
});
```

Apply the same pattern to ALL service providers.

### Step 2f — Remove the hardcoded demoMode flag

In `lib/core/constants/app_constants.dart`, remove or comment out:
```dart
// REMOVED: static const bool demoMode = true;
// Backend availability is now determined at runtime by BackendMonitor
```

Search the entire codebase for `AppConstants.demoMode` and remove all references. The `backendAvailableProvider` replaces it everywhere.

---

## Task 3 — Fix login screen

**File:** `lib/screens/auth/login_screen.dart`

### What needs to change:
1. Convert `StatefulWidget` → `ConsumerStatefulWidget`
2. `_login()` and `_quickLogin()` must call `ref.read(authProvider.notifier).demoLogin()` or `ref.read(authProvider.notifier).login()`
3. After login, navigate based on role from Riverpod state, NOT from `LoginRoleStorage`
4. Show actual error messages

### Add `demoLogin` to `AuthNotifier` in `providers.dart`

Inside the `AuthNotifier` class, after the `logout()` method, add:

```dart
// Demo login — sets Riverpod state directly without hitting backend
Future<void> demoLogin({
  required String name,
  required String email,
  required String role,
}) async {
  state = state.copyWith(isLoading: true);
  await Future.delayed(const Duration(milliseconds: 600));
  // save role to storage so it persists on hot restart
  await _authService.tokenStorage.saveRole(role);
  state = AuthState(
    isLoggedIn: true,
    token: 'demo-token-\$role',
    role: role,
    userId: 'demo-\$role-001',
    name: name,
    email: email,
    isLoading: false,
  );
}
```

### Make `tokenStorage` accessible from `AuthService`

In `lib/services/auth_service.dart`:
```dart
// Change private field to public:
// FROM:  final TokenStorage _tokenStorage;
// TO:
final TokenStorage tokenStorage;

// Change constructor accordingly:
// FROM:  AuthService(this._client, this._tokenStorage);
// TO:
AuthService(this._client, this.tokenStorage);

// Update all internal references from _tokenStorage to tokenStorage
```

### Update login screen navigation

After a successful login, navigate based on role:

```dart
void _navigateByRole() {
  final role = ref.read(authProvider).role;
  switch (role) {
    case 'admin':
      Navigator.pushReplacementNamed(context, '/home');
      break;
    case 'advisor':
      Navigator.pushReplacementNamed(context, '/home');
      break;
    default:
      Navigator.pushReplacementNamed(context, '/home');
  }
}
```

Note: ALL roles go to `/home` — the shell reads the role and renders the right dashboard. Do not route to `/admin-dashboard` or `/advisor-dashboard` directly.

---

## Task 4 — Fix the main shell (most important for demo)

**File:** `lib/screens/main_shell_screen.dart`

The shell must be role-aware. It wraps ALL roles. Each role gets different tabs.

### Role → tabs mapping:

**Founder tabs:**
- Dashboard (Icons.dashboard_rounded)
- Forecast (Icons.trending_up_rounded)
- AI Chat (Icons.smart_toy_rounded)
- Reports (Icons.receipt_long_rounded)
- More (Icons.menu_rounded) → marketplace, fundraising, notifications, profile

**Advisor tabs:**
- My Clients (Icons.people_rounded) → AdvisorDashboardScreen
- Schedule (Icons.calendar_today_rounded) → placeholder for now
- AI Tools (Icons.smart_toy_rounded) → AiChatScreen
- Profile (Icons.person_rounded) → ProfileScreen

**Admin tabs:**
- Platform (Icons.analytics_rounded) → AdminDashboardScreen
- Users (Icons.people_rounded) → placeholder for now
- Advisors (Icons.verified_user_rounded) → placeholder for now
- Reports (Icons.bar_chart_rounded) → ReportsScreen
- Settings (Icons.settings_rounded) → placeholder for now

### Logout button

ALL roles get a logout button. Add it to the AppBar actions on every tab:

```dart
IconButton(
  icon: const Icon(Icons.logout_rounded),
  onPressed: () async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  },
  tooltip: 'Logout',
)
```

### Full replacement for `main_shell_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../providers/providers.dart';
import 'dashboard/founder_dashboard_screen.dart';
import 'dashboard/advisor_dashboard_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'forecasting/forecast_screen.dart';
import 'ai_assistant/chat_screen.dart';
import 'reports/reports_screen.dart';
import 'profile/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  // Reset tab index when role changes (e.g. after re-login)
  String _lastRole = '';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final role = auth.role;

    // Reset to tab 0 if role changed
    if (_lastRole != role) {
      _lastRole = role;
      _currentIndex = 0;
    }

    final config = _getConfig(role);
    final screens = config['screens'] as List<Widget>;
    final tabs = config['tabs'] as List<Map<String, dynamic>>;

    return Scaffold(
      // Each screen is responsible for its own AppBar.
      // Shell only provides the bottom nav and logout.
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = _currentIndex == i;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (tab['action'] != null) {
                      (tab['action'] as VoidCallback)();
                    } else {
                      setState(() => _currentIndex = i);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 22,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textHint,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String role) {
    switch (role) {
      case 'advisor':
        return {
          'screens': [
            const AdvisorDashboardScreen(),
            const AiChatScreen(),
            const ProfileScreen(),
            _buildLogoutScreen(),
          ],
          'tabs': [
            {'icon': Icons.people_rounded, 'label': 'Clients'},
            {'icon': Icons.smart_toy_rounded, 'label': 'AI Tools'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
            {
              'icon': Icons.logout_rounded,
              'label': 'Logout',
              'action': _logout,
            },
          ],
        };
      case 'admin':
        return {
          'screens': [
            const AdminDashboardScreen(),
            const ReportsScreen(),
            const ProfileScreen(),
            _buildLogoutScreen(),
          ],
          'tabs': [
            {'icon': Icons.analytics_rounded, 'label': 'Platform'},
            {'icon': Icons.bar_chart_rounded, 'label': 'Reports'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
            {
              'icon': Icons.logout_rounded,
              'label': 'Logout',
              'action': _logout,
            },
          ],
        };
      default: // founder
        return {
          'screens': [
            const FounderDashboardScreen(),
            const ForecastScreen(),
            const AiChatScreen(),
            const ReportsScreen(),
            _buildMoreMenu(),
          ],
          'tabs': [
            {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
            {'icon': Icons.trending_up_rounded, 'label': 'Forecast'},
            {'icon': Icons.smart_toy_rounded, 'label': 'AI'},
            {'icon': Icons.receipt_long_rounded, 'label': 'Reports'},
            {'icon': Icons.menu_rounded, 'label': 'More'},
          ],
        };
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildLogoutScreen() {
    // Never actually shown — logout tab triggers action directly
    return const SizedBox.shrink();
  }

  Widget _buildMoreMenu() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            Icons.store_rounded,
            'Marketplace',
            'Find and book CFO advisors',
            AppTheme.info,
            () => Navigator.pushNamed(context, '/marketplace'),
          ),
          _menuCard(
            Icons.volunteer_activism_rounded,
            'Fundraising',
            'Readiness score & data room',
            AppTheme.success,
            () => Navigator.pushNamed(context, '/fundraising'),
          ),
          _menuCard(
            Icons.notifications_rounded,
            'Notifications',
            'Alerts and updates',
            AppTheme.warning,
            () => Navigator.pushNamed(context, '/notifications'),
          ),
          _menuCard(
            Icons.person_rounded,
            'Profile',
            'Account & company info',
            AppTheme.primary,
            () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Task 5 — Rebuild admin dashboard mock data

**File:** `lib/services/mock_data_service.dart`

Add this method to `MockDataService` (the singleton class):

```dart
Map<String, dynamic> getMockAdminMetrics() {
  return {
    'totalFounders': 342,
    'totalAdvisors': 28,
    'totalCompanies': 156,
    'activeThisMonth': 245,
    'platformRevenue': 1250000,
    'platformRevenueChange': 8.4,
    'totalBookings': 89,
    'bookingsChange': 12.0,
    'avgSessionMinutes': 18,
    'uptime': 99.9,
    'planDistribution': {
      'premium': 42,
      'standard': 89,
      'basic': 211,
    },
    'recentSignups': [
      {'name': 'NeoFinance Ltd', 'role': 'founder', 'plan': 'Premium', 'daysAgo': 1},
      {'name': 'Dr. Priya Mehta', 'role': 'advisor', 'plan': 'Pro', 'daysAgo': 2},
      {'name': 'GreenScale Inc', 'role': 'founder', 'plan': 'Standard', 'daysAgo': 3},
      {'name': 'HealthBridge Co', 'role': 'founder', 'plan': 'Basic', 'daysAgo': 4},
      {'name': 'Dr. Arun Nair', 'role': 'advisor', 'plan': 'Pro', 'daysAgo': 5},
    ],
    'advisorPipeline': [
      {'name': 'Sarah Chen', 'status': 'Verified', 'clients': 8, 'rating': 4.9},
      {'name': 'Marcus Johnson', 'status': 'Verified', 'clients': 6, 'rating': 4.8},
      {'name': 'Priya Patel', 'status': 'Verified', 'clients': 11, 'rating': 4.9},
      {'name': 'Michael Brown', 'status': 'Pending', 'clients': 0, 'rating': 0.0},
      {'name': 'James Wilson', 'status': 'Suspended', 'clients': 0, 'rating': 4.7},
    ],
    'monthlyGrowth': [
      {'month': 'Jan', 'founders': 280, 'revenue': 980000},
      {'month': 'Feb', 'founders': 295, 'revenue': 1020000},
      {'month': 'Mar', 'founders': 308, 'revenue': 1080000},
      {'month': 'Apr', 'founders': 315, 'revenue': 1120000},
      {'month': 'May', 'founders': 328, 'revenue': 1180000},
      {'month': 'Jun', 'founders': 342, 'revenue': 1250000},
    ],
    'alerts': [
      {'type': 'warning', 'message': 'Michael Brown verification pending for 5 days'},
      {'type': 'info', 'message': '3 new founder signups in the last 24 hours'},
      {'type': 'success', 'message': 'Platform uptime maintained at 99.9% this month'},
    ],
  };
}
```

---

## Task 6 — Rebuild admin dashboard screen

**File:** `lib/screens/dashboard/admin_dashboard_screen.dart`

**Replace entirely.** The new admin dashboard must show:
- Header with platform name + live/mock badge
- 4 KPI cards: Total Founders, Total Advisors, Platform Revenue (₹), Active Users
- Platform growth hint ("+8.4% this month")
- Advisor pipeline list with status badges (Verified/Pending/Suspended)
- Recent signups list (last 5)
- 3 platform alerts (warning/info/success)
- Plan distribution row (Premium / Standard / Basic counts)

Use `MockDataService().getMockAdminMetrics()` as data source.

Color conventions (already in AppTheme):
- `AppTheme.success` for Verified / success alerts
- `AppTheme.warning` for Pending / warning alerts
- `AppTheme.error` for Suspended
- `AppTheme.info` for info alerts
- `AppTheme.accentGold` for Premium badge
- `AppTheme.primary` for Standard badge
- `AppTheme.textSecondary` for Basic badge

Structure the build method like this:

```dart
@override
Widget build(BuildContext context) {
  final data = MockDataService().getMockAdminMetrics();

  return Scaffold(
    backgroundColor: AppTheme.backgroundLight,
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(data),
            const SizedBox(height: 16),
            _buildKpiGrid(data),
            const SizedBox(height: 20),
            _buildAlerts(data),
            const SizedBox(height: 20),
            _buildPlanDistribution(data),
            const SizedBox(height: 20),
            _buildAdvisorPipeline(data),
            const SizedBox(height: 20),
            _buildRecentSignups(data),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
```

Implement each `_build*` method. Keep cards consistent with the existing style:
- White background, `borderRadius: BorderRadius.circular(14)`
- Subtle shadow: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))`
- Section titles: 16px bold, `AppTheme.textPrimary`, with a leading icon

---

## Task 7 — Rebuild advisor dashboard screen

**File:** `lib/screens/dashboard/advisor_dashboard_screen.dart`

Add this mock data method to `MockDataService`:

```dart
Map<String, dynamic> getMockAdvisorMetrics() {
  return {
    'advisorName': 'Sarah Chen',
    'specialization': 'SaaS & Enterprise',
    'rating': 4.9,
    'totalClients': 8,
    'activeEngagements': 5,
    'completedSessions': 47,
    'upcomingBookings': [
      {'client': 'TechFlow Inc.', 'date': 'Jun 18', 'time': '10:00 AM', 'topic': 'Runway analysis'},
      {'client': 'NeoFinance', 'date': 'Jun 20', 'time': '2:00 PM', 'topic': 'Series A prep'},
      {'client': 'GreenScale', 'date': 'Jun 22', 'time': '11:00 AM', 'topic': 'Cash flow review'},
    ],
    'clientHealth': [
      {'name': 'TechFlow Inc.', 'runway': 13, 'status': 'healthy'},
      {'name': 'NeoFinance', 'runway': 7, 'status': 'warning'},
      {'name': 'GreenScale', 'runway': 4, 'status': 'critical'},
      {'name': 'EduLearn', 'runway': 18, 'status': 'healthy'},
      {'name': 'HealthPlus', 'runway': 11, 'status': 'healthy'},
    ],
    'recentActivity': [
      {'client': 'TechFlow Inc.', 'action': 'Session completed', 'daysAgo': 2},
      {'client': 'NeoFinance', 'action': 'Report shared', 'daysAgo': 3},
      {'client': 'GreenScale', 'action': 'Alert: Low runway', 'daysAgo': 4},
    ],
  };
}
```

Rebuild the advisor dashboard to show:
- Header with advisor name, specialization, star rating
- 3 KPI cards: Active Clients, Completed Sessions, Upcoming Bookings
- Upcoming bookings list (client, date, time, topic)
- Client health list — runway in months, color coded:
  - runway ≥ 12 → `AppTheme.success` "Healthy"
  - runway 6-11 → `AppTheme.warning` "Watch"
  - runway < 6 → `AppTheme.error` "Critical"

---

## Execution order

Run these in sequence. After each one, do `flutter run -d linux` and confirm no red errors before moving to the next.

1. Task 1 — main.dart (1 file, 15 lines)
2. Task 3 — auth_service.dart tokenStorage field (2 line change)
3. Task 3 — providers.dart add demoLogin to AuthNotifier
4. Task 3 — login_screen.dart (convert to ConsumerStatefulWidget, wire to authProvider)
5. Task 4 — main_shell_screen.dart (full replacement)
6. Task 5 — mock_data_service.dart (add getMockAdminMetrics + getMockAdvisorMetrics)
7. Task 6 — admin_dashboard_screen.dart (full replacement)
8. Task 7 — advisor_dashboard_screen.dart (full replacement)
9. Task 2 — backend fallback (do this last — it's additive and touches many files)
10. BUG-002 — token_storage.dart one-line fix (can do anytime)

---

## How to verify each task worked

**After Task 1:** App launches without crash. No "null token" errors in console.

**After Tasks 3+4:** Tap "Founder" quick login → lands on founder dashboard. Tap back, tap "Advisor" → lands on advisor dashboard. Tap back, tap "Admin" → lands on admin dashboard.

**After Task 4 (shell):** All three roles show bottom nav. Tapping logout on any role returns to login screen. Role shown in the correct dashboard.

**After Tasks 5-7:** Admin dashboard shows platform metrics, advisor pipeline, recent signups. Advisor dashboard shows client health with color-coded runway.

**After Task 2 (backend fallback):** Start app with no backend running → works normally with mock data. Start backend (`cd Backend && npm install && node server.js`) → app picks it up within 30 seconds and switches to real data.

---

## Things DeepSeek must NOT do

- Do not rename any existing providers in `providers.dart` — other screens depend on them
- Do not change response shapes in any service — they must match `DashboardMetrics.fromJson()` etc.
- Do not add new routes to `app.dart` unless explicitly needed
- Do not modify any files in `lib/models/` — they are correct as-is
- Do not use `setState` for auth state — it must go through `authProvider.notifier`
- Do not hardcode colors — use `AppTheme.*` constants always
- Do not add new dependencies to `pubspec.yaml` without checking if they're already there

---

## If something breaks

Common Flutter errors and what they mean:

`type 'Null' is not a subtype of type 'X'` → a `.fromJson()` got a null field. Check the mock data matches the model's expected keys exactly.

`The method 'X' isn't defined for the type 'AuthNotifier'` → `demoLogin` wasn't added to AuthNotifier in providers.dart.

`Could not find the correct Provider above this Widget` → a ConsumerWidget is trying to read a provider but isn't wrapped in ProviderScope. Check main.dart has ProviderScope wrapping CfoApp.

`setState() called after dispose()` → add `if (!mounted) return;` before any `setState()` call that follows an `await`.

`Navigator operation requested with a context that does not include a Navigator` → the widget calling Navigator is not inside MaterialApp's navigator. Usually happens when a widget outside the route tree tries to navigate. Fix: pass context down or use a GlobalKey<NavigatorState>.

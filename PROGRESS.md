# The Scalable CFO — Project State
> READ THIS FIRST before touching any code. Update it when you finish a session.

## What this app is
A financial co-pilot for startup founders. Three roles: **founder**, **advisor**, **admin**.
- Flutter frontend (web / android / ios / linux / macos / windows)
- Node.js backend at `Backend/` (port 3001)
- Current state: **demo mode** — frontend runs entirely on mock data, no backend needed

## Stack
| Layer | Tech | Location |
|-------|------|----------|
| Frontend | Flutter + Riverpod | `Frontend/cfo/lib/` |
| State management | Riverpod (StateNotifier + FutureProvider) | `lib/providers/providers.dart` |
| API client | Custom HTTP wrapper | `lib/core/network/api_client.dart` |
| Token storage | SharedPreferences (cached sync) | `lib/core/storage/token_storage.dart` |
| Backend | Node.js + Express (assumed) | `Backend/src/` |
| Mock data | MockDataService singleton | `lib/services/mock_data_service.dart` |

## Current demo mode flag
```dart
// lib/core/constants/app_constants.dart
static const bool demoMode = true;  // ← flip to false to use real backend
```

---

## KNOWN BUGS (do not ignore)

### BUG-001 — TokenStorage not initialized before use
**File:** `lib/main.dart` + `lib/core/storage/token_storage.dart`
**Problem:** `getToken()` returns `_cachedToken` which is null until `init()` or `loadCachedData()` is called. Neither is called in `main()`. Auth state is phantom on cold start.
**Fix needed:** In `main()`, after `WidgetsFlutterBinding.ensureInitialized()`, instantiate `TokenStorage` and call `await tokenStorage.loadCachedData()` before `runApp()`. Pass it into `ProviderScope` via override.
**Assigned to:** Claude (touches Riverpod bootstrap)

### BUG-002 — saveUserData saves toString() not JSON
**File:** `lib/core/storage/token_storage.dart` line ~38
**Problem:** `prefs.setString(AppConstants.userKey, user.toString())` — `Map.toString()` is not JSON, cannot be deserialized.
**Fix needed:** Replace with `import 'dart:convert'; prefs.setString(AppConstants.userKey, jsonEncode(user));`
**Assigned to:** Any model (one-line fix)

### BUG-003 — Login bypasses AuthNotifier entirely
**File:** `lib/screens/auth/login_screen.dart` method `_login()`
**Problem:** Login just delays 800ms and calls `Navigator.pushReplacementNamed`. It doesn't call `ref.read(authProvider.notifier).login(email, password)`. Role is stored in static `LoginRoleStorage.currentRole`, not in Riverpod state.
**Fix needed:** Convert LoginScreen to ConsumerStatefulWidget, call `authProvider.notifier.login()`, handle errors, then navigate.
**Assigned to:** Claude (touches Riverpod)

### BUG-004 — signup silently logs in on 409
**File:** `lib/services/auth_service.dart`
**Problem:** If signup returns 409 (email exists), it silently attempts login with the same password — could log someone into an existing account by mistake.
**Fix needed:** Throw a user-facing error instead. "Email already registered. Please log in."
**Assigned to:** Any model (backend + frontend)

### BUG-005 — AI chat mock is deterministic garbage
**File:** `lib/services/mock_data_service.dart` method `mockChat()`
**Problem:** Response picked by `responses[message.length % responses.length]`. Always the same 5 rotating responses.
**Fix needed (demo mode):** Either call real Anthropic API directly from Flutter in demo mode, or improve mock to at least keyword-match.
**Fix needed (real mode):** Backend `/ai/chat` must be wired to an actual LLM.
**Assigned to:** Claude (demo mode fix) / DeepSeek (backend route)

---

## COMPLETED
- [ ] Nothing merged to main yet — all work is in progress

---

## SESSION LOG
> Add an entry every time you finish a session so the next model/session knows where you left off.

### 14/06/2026 — Cline (Claude)
- Fixed compilation errors preventing app from running
- **Bug fix BUG-003 extension**: `main_shell_screen.dart` still referenced non-existent `LoginRoleStorage` — converted to `ConsumerStatefulWidget` and reads role from `ref.watch(authProvider).role`
- **Bug fix**: `AuthService.tokenStorage` was private (`_tokenStorage`) causing `providers.dart` line 152 to fail accessing `_authService._tokenStorage` — renamed to public `tokenStorage`
- Removed unused import of `models/user.dart` in `auth_service.dart`
- App builds and runs successfully with `flutter build web`
- **Left unfinished**: BUG-004 (signup silently logs in on 409), BUG-005 (AI chat mock deterministic), deprecated `withOpacity` -> `withValues` migration
- **Files modified**:
  - `Frontend/cfo/lib/services/auth_service.dart`
  - `Frontend/cfo/lib/screens/main_shell_screen.dart`

---

## FILE MAP (critical files only)
```
lib/
├── main.dart                          ← app entry point (needs TokenStorage init)
├── app.dart                           ← routes + MaterialApp
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         ← demoMode flag HERE
│   │   └── api_constants.dart         ← all backend URLs
│   ├── network/
│   │   ├── api_client.dart            ← HTTP wrapper (get/post/patch/put)
│   │   └── api_exception.dart         ← error type
│   └── storage/
│       └── token_storage.dart         ← BUG-001, BUG-002 live here
├── models/                            ← plain data classes, safe to modify
├── providers/
│   └── providers.dart                 ← ALL Riverpod state lives here (CAREFUL)
├── screens/
│   ├── auth/
│   │   └── login_screen.dart          ← BUG-003 lives here
│   ├── dashboard/                     ← founder/advisor/admin dashboards
│   ├── forecasting/
│   ├── ai_assistant/
│   ├── reports/
│   ├── marketplace/
│   ├── fundraising/
│   ├── notifications/
│   └── profile/
└── services/
    ├── mock_data_service.dart         ← ALL demo data (singleton)
    ├── auth_service.dart              ← BUG-004 lives here
    ├── ai_service.dart                ← calls /ai/chat
    └── [other services]              ← one per feature, all call ApiClient
```

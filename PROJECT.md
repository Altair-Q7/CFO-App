# The Scalable CFO

A financial co-pilot for startup founders. Three roles: **founder**, **advisor**, **admin**.

| Layer | Tech | Location |
|-------|------|----------|
| Frontend | Flutter + Riverpod | `Frontend/cfo/lib/` |
| State management | Riverpod (StateNotifier + FutureProvider) | `lib/providers/providers.dart` |
| API client | Custom HTTP wrapper | `lib/core/network/api_client.dart` |
| Token storage | SharedPreferences | `lib/core/storage/token_storage.dart` |
| Backend | Node.js + Express + SQLite | `Backend/` (port 3001) |
| Mock data | MockDataService singleton | `lib/services/mock_data_service.dart` |

---

## Quick Start

```bash
# Frontend (linux desktop — fastest for dev)
cd Frontend/cfo
flutter run -d linux

# Backend
cd Backend
npm install
cp .env.example .env   # fill in JWT_SECRET
node server.js
```

---

## Project Structure

```
CFO App/
├── Backend/                         ← Node.js + Express + SQLite
│   ├── server.js                    ← entry point, port 3001
│   ├── package.json
│   └── src/
│       ├── database/
│       │   ├── connection.js
│       │   └── seed.js
│       ├── middleware/
│       │   └── auth.js              ← JWT middleware
│       ├── routes/                   ← one file per feature
│       │   ├── auth.js
│       │   ├── dashboard.js
│       │   ├── aiAssistant.js
│       │   ├── forecasting.js
│       │   ├── reports.js
│       │   ├── marketplace.js
│       │   ├── fundraising.js
│       │   ├── notifications.js
│       │   └── profile.js
│       └── services/
│           ├── aiResponses.js
│           ├── forecastingEngine.js
│           ├── mockDataGenerator.js
│           └── pdfGenerator.js
│
├── Frontend/cfo/
│   └── lib/
│       ├── main.dart                ← app entry point
│       ├── app.dart                 ← routes + MaterialApp
│       ├── core/
│       │   ├── constants/
│       │   │   ├── app_constants.dart    ← AppTheme + AppConstants
│       │   │   └── api_constants.dart
│       │   ├── network/
│       │   │   ├── api_client.dart
│       │   │   └── api_exception.dart
│       │   └── storage/
│       │       └── token_storage.dart
│       ├── models/                   ← plain Dart data classes
│       ├── providers/
│       │   └── providers.dart        ← ALL Riverpod providers (CAREFUL)
│       ├── screens/
│       │   ├── auth/
│       │   │   └── login_screen.dart
│       │   ├── dashboard/
│       │   │   ├── founder_dashboard_screen.dart
│       │   │   ├── advisor_dashboard_screen.dart
│       │   │   └── admin_dashboard_screen.dart
│       │   ├── settings/
│       │   │   └── settings_screen.dart
│       │   ├── main_shell_screen.dart
│       │   ├── forecasting/
│       │   ├── ai_assistant/
│       │   ├── reports/
│       │   ├── marketplace/
│       │   ├── fundraising/
│       │   ├── notifications/
│       │   └── profile/
│       ├── widgets/
│       │   ├── madi_briefing_card.dart
│       │   └── madi_presence_indicator.dart
│       └── services/
│           ├── mock_data_service.dart
│           ├── auth_service.dart
│           ├── ai_service.dart
│           └── [other services]
│
├── AGENTS.md              ← AI agent instructions
├── CONTRACT.md            ← Backend API contract (response shapes)
├── PROGRESS.md            ← Session log + known bugs
├── PROJECT.md             ← This file
```

---

## Architecture

### State Management (Riverpod)
- `authProvider` — `StateNotifier<AuthState>` — login/logout/session
- `backendAvailableProvider` — `StateProvider<bool>` — backend health check
- Service providers instantiated per-feature with `useMock` flag based on backend availability
- All screens that use auth are `ConsumerStatefulWidget`

### API Layer
- `ApiClient` — HTTP wrapper handling GET/POST/PATCH/PUT
- Services call `ApiClient` when backend is available, fall back to `MockDataService` when offline
- Error responses from backend always use `{ "error": "message" }` format
- JWT stored in `SharedPreferences` via `TokenStorage`

### Mock Data
- `MockDataService` is a singleton providing all demo data
- Active when backend is unavailable (default state)
- Provides mock data for: metrics, trends, transactions, notifications, forecasts, advisors, reports, fundraising, admin/advisor dashboards, MADI briefings

---

## Key Features

| Feature | Route | Screen |
|---------|-------|--------|
| Founder Dashboard | `/home` | `founder_dashboard_screen.dart` |
| Advisor Dashboard | `/home` | `advisor_dashboard_screen.dart` |
| Admin Dashboard | `/home` | `admin_dashboard_screen.dart` |
| Forecasting | `/forecast` | `forecast_screen.dart` |
| AI Chat | `/ai-chat` | `chat_screen.dart` |
| Reports | `/reports` | `reports_screen.dart` |
| Marketplace | `/marketplace` | `marketplace_list_screen.dart` |
| Fundraising | `/fundraising` | `fundraising_screen.dart` |
| Notifications | `/notifications` | `notifications_screen.dart` |
| Profile | `/profile` | `profile_screen.dart` |
| Settings | `/settings` | `settings_screen.dart` |

---

## MADI — Financial Operations Intelligence

MADI is a Financial Operations Intelligence System — not a chatbot. Analytical. Direct. Professional.

### Components
| Widget | File | Purpose |
|--------|------|---------|
| `MadiBriefingCard` | `lib/widgets/madi_briefing_card.dart` | Pre-computed financial briefing with status-colored left border (4 sentences, action link) |
| `MadiPresenceIndicator` | `lib/widgets/madi_presence_indicator.dart` | Gold pulsing dot + "MADI · 2h ago" — shown on every screen's AppBar |
| `SettingsScreen` | `lib/screens/settings/settings_screen.dart` | App settings: account, preferences, about, logout |

### Briefing Card
- **States:** `healthy` (emerald), `warning` (amber), `critical` (coral)
- **Constraints:** Max 4 sentences, every sentence has a number or decision, no motivational language
- **Data:** `MockDataService.getMadiBriefing*()` methods (3 variants: warning/healthy/critical)

### Presence Indicator
- Gold pulsing dot using `AnimatedBuilder` with 2s ease-in-out loop
- Shows "MADI · {lastReviewed}" text
- Used in AppBar actions on founder dashboard and admin dashboard

---

## Design System

All colors via `AppTheme` in `lib/core/constants/app_constants.dart`:

### Colors
| Category | Constants |
|----------|-----------|
| Dark surfaces | `darkBase` `#0A0F1E`, `darkSurface` `#111827`, `darkElevated` `#1F2937`, `darkBorder` `#374151` |
| Light surfaces | `lightBase` `#F8FAFC`, `lightSurface` `#FFFFFF`, `lightElevated` `#F1F5F9`, `lightBorder` `#E2E8F0` |
| Navy brand | `navyDeep` `#0B1F3A`, `navyMid` `#1A3A5C`, `navyLight` `#234E7A` |
| Semantic | `emerald` `#10B981`, `amber` `#F59E0B`, `coral` `#EF4444`, `gold` `#D4AF37` |
| Text | `textPrimary` `#0F172A`, `textSecondary` `#64748B`, `textMuted` `#94A3B8`, `textOnDark` `#F8FAFC` |

### Typography
| Style | Usage |
|-------|-------|
| `labelStyle` | 11px, w600, 1.2 spacing — section labels |
| `metricLarge` | 32px, w700, -1.0 tracking — primary metric values |
| `metricMedium` | 22px, w700, -0.5 tracking — secondary metric values |
| `madiBriefingText` | 15px, w500, 1.7 height — MADI briefing copy |
| `bodyText` | 14px, w400, 1.5 height — body copy |

### Card style
- Standard: white bg, `borderRadius: 16`, `lightBorder` border, subtle shadow `(alpha 0.04, blur 12)`
- Dark: `navyGradient` bg, white border `(alpha 0.08)`, used for MADI and admin headers
- Section labels: 11px, w600, `textSecondary`, `letterSpacing 1.2`
- Page background: `lightBase`

---

## Backend API

Full contract in `CONTRACT.md`. Key endpoints:

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | `/api/auth/signup` | No | Register |
| POST | `/api/auth/login` | No | Login |
| GET | `/api/health` | No | Backend health |
| GET | `/api/dashboard/metrics` | Yes | KPIs |
| GET | `/api/dashboard/trends` | Yes | Monthly trends |
| GET | `/api/dashboard/activity` | Yes | Transactions + notifications |
| POST | `/api/forecasting/project` | Yes | Run projections |
| POST | `/api/ai/chat` | Yes | AI chat |
| GET | `/api/reports/:type` | Yes | PnL / Balance Sheet / Cash Flow |
| GET | `/api/marketplace/advisors` | No | List advisors |
| POST | `/api/marketplace/book` | Yes | Book an advisor |
| GET | `/api/fundraising/readiness` | Yes | Fundraising score |
| GET | `/api/notifications` | Yes | Notifications list |
| GET | `/api/profile` | Yes | User + company profile |

JWT payload: `{ userId, role, email }`, 7-day expiry.

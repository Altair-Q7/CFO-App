# Next Session Checklist
> Do these IN ORDER. Don't jump ahead.

## Phase 1 — Make the backend visible (DeepSeek / Cline)
These don't require knowing Dart at all.

- [ ] **1.1** `cat Backend/server.js` and `ls Backend/src/` — paste output to DeepSeek, ask: "Does this backend implement the routes in CONTRACT.md? Which ones are missing?"
- [ ] **1.2** `cat Backend/package.json` — check what DB it uses (sqlite? postgres? mongo?)
- [ ] **1.3** Run `cd Backend && npm install && node server.js` — does it start?
- [ ] **1.4** Run `bash test_endpoints.sh` or `node test_endpoints.js` — which routes pass?
- [ ] **1.5** Fill in any missing routes using CONTRACT.md as the spec. DeepSeek can do this.

## Phase 2 — Fix the Flutter auth (Claude)
Requires a Claude session. Do this AFTER backend is running.

- [ ] **2.1** Fix BUG-002 first (one line, `jsonEncode`)
- [ ] **2.2** Fix BUG-001: add `TokenStorage` init to `main()`
- [ ] **2.3** Fix BUG-003: wire `LoginScreen` to `authProvider.notifier.login()`
- [ ] **2.4** Test: run app, log in as founder, verify role shows correctly in shell

## Phase 3 — Connect frontend to backend (Claude)
- [ ] **3.1** Set `demoMode = false` in `app_constants.dart`
- [ ] **3.2** Update `ApiConstants.baseUrl` to point at deployed backend (or keep localhost for dev)
- [ ] **3.3** Fix each service: currently all services use `MockDataService` when `demoMode=true` — wire them to real `ApiClient` calls
- [ ] **3.4** Handle errors properly: replace silent `catch (e) { return null; }` with user-facing error states

## Phase 4 — AI chat (split work)
- [ ] **4.1** Backend: DeepSeek implements `/ai/chat` route that proxies to OpenAI/Anthropic with company context in system prompt
- [ ] **4.2** Frontend: Claude wires `AiChatNotifier` to real backend, removes mock rotating responses

## Phase 5 — UI polish (last, not first)
Only after everything above works. The app works ugly. It doesn't work broken.

---

## Quick reference: how to run the app

```bash
# Backend
cd "CFO App/Backend"
npm install
cp .env.example .env   # fill in JWT_SECRET and DB config
node server.js         # or: npm run dev

# Frontend (web)
cd "CFO App/Frontend/cfo"
flutter run -d chrome

# Frontend (linux desktop — fastest for dev)
flutter run -d linux
```

## How to test a backend route manually
```bash
# Health check
curl http://localhost:3001/api/health

# Login (get token)
TOKEN=$(curl -s -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}' | jq -r '.token')

# Authenticated request
curl http://localhost:3001/api/dashboard/metrics \
  -H "Authorization: Bearer $TOKEN"
```

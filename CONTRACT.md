# Backend CONTRACT
> This document defines what the backend MUST return for each endpoint.
> DeepSeek / Cline: implement these exactly. Do not invent new response shapes.
> Claude will update this doc if shapes change — check git log before implementing.

## Base URL
```
http://localhost:3001/api
```

## Auth headers
All endpoints except `/auth/*` require:
```
Authorization: Bearer <jwt_token>
```
Return `401` if missing or invalid.

---

## Auth

### POST /auth/signup
Request:
```json
{ "name": "string", "email": "string", "password": "string", "role": "founder|advisor|admin" }
```
Success `201`:
```json
{
  "token": "jwt_string",
  "user": { "id": "uuid", "name": "string", "email": "string", "role": "founder", "hasCompany": false }
}
```
Error `409` if email exists: `{ "error": "Email already registered" }`
Error `400` for missing fields: `{ "error": "Name, email, password and role are required" }`

### POST /auth/login
Request: `{ "email": "string", "password": "string" }`
Success `200`:
```json
{
  "token": "jwt_string",
  "user": { "id": "uuid", "name": "string", "email": "string", "role": "founder" }
}
```
Error `401`: `{ "error": "Invalid credentials" }`

### POST /auth/forgot-password
Request: `{ "email": "string" }`
Success `200`: `{ "message": "If that email exists, a reset link was sent" }`
(Always return 200 — don't leak whether email exists)

### POST /auth/onboarding
Auth required. Request:
```json
{
  "companyName": "string",
  "industry": "string",
  "monthlyRevenue": 0,
  "monthlyExpenses": 0,
  "employees": 0
}
```
Success `200`: `{ "message": "Onboarding complete", "company": { ...company object } }`

---

## Dashboard

### GET /dashboard/metrics
Auth required.
Success `200`:
```json
{
  "cashBalance": 1245000,
  "monthlyRevenue": 185000,
  "monthlyExpenses": 125000,
  "netProfit": 60000,
  "burnRate": 95000,
  "runway": 13,
  "revenueChange": 12.5,
  "expenseChange": 3.2,
  "profitMargin": 32.4,
  "companyName": "string",
  "industry": "string",
  "employees": 28
}
```

### GET /dashboard/trends
Auth required.
Returns last 12 months of monthly financial data.
Success `200`:
```json
{
  "trends": [
    { "date": "2025-07", "revenue": 120000, "expenses": 85000, "cashBalance": 500000, "actual": true }
  ]
}
```

### GET /dashboard/activity
Auth required.
```json
{
  "transactions": [
    { "id": "string", "date": "YYYY-MM-DD", "description": "string", "amount": 45000, "type": "income|expense", "category": "string" }
  ],
  "notifications": [
    { "id": "string", "title": "string", "message": "string", "type": "info|warning|success|error", "read": false, "createdAt": "ISO8601" }
  ]
}
```

---

## Forecasting

### POST /forecasting/project
Auth required. Request:
```json
{ "months": 12, "revenueGrowth": 5.0, "expenseGrowth": 3.0, "hiringCost": 0 }
```
Success `200`:
```json
{
  "historical": [ { "date": "2025-07", "revenue": 0, "expenses": 0, "cashBalance": 0, "actual": true, "month": 1 } ],
  "projections": [ { "date": "2026-01", "revenue": 0, "expenses": 0, "cash_balance": 0, "month": 1 } ],
  "currentCash": 1245000,
  "currentBurnRate": 95000,
  "currentRunway": 13
}
```
NOTE: projections use `cash_balance` (snake_case) — matches Flutter model, do not change.

---

## AI

### POST /ai/chat
Auth required. Request:
```json
{ "message": "string", "history": [ { "role": "user|assistant", "content": "string" } ] }
```
Success `200`:
```json
{
  "response": "string",
  "metrics": null,
  "suggestedQuestions": ["string", "string", "string"]
}
```
Backend should call an LLM (OpenAI / Anthropic) with the company's financial context prepended as system prompt.

### GET /ai/history
Auth required.
```json
{ "history": [ { "role": "user|assistant", "content": "string", "createdAt": "ISO8601" } ] }
```

### GET /ai/suggestions
No auth required (public endpoint for onboarding prompts).
```json
{ "suggestions": ["How is my runway?", "Analyze my burn rate", "Am I ready to fundraise?"] }
```

---

## Reports

### GET /reports/:type
Auth required. `:type` = `pnl` | `balance-sheet` | `cash-flow`

For `pnl`, success `200`:
```json
{
  "type": "pnl",
  "data": {
    "totalRevenue": 185000, "cogs": 42500, "grossProfit": 142500,
    "totalExpenses": 82500, "netProfit": 60000,
    "revenueGrowth": 12.5, "profitMargin": 32.4, "operatingRatio": 44.6
  }
}
```

For `balance-sheet`, success `200`:
```json
{
  "type": "balance-sheet",
  "data": {
    "assets": [ { "name": "string", "value": 0 } ],
    "totalAssets": 0,
    "liabilities": [ { "name": "string", "value": 0 } ],
    "totalLiabilities": 0,
    "equity": [ { "name": "string", "value": 0 } ],
    "totalEquity": 0
  }
}
```

For `cash-flow`, success `200`:
```json
{
  "type": "cash-flow",
  "data": {
    "operating": [ { "description": "string", "value": 0 } ],
    "netOperating": 0,
    "investing": [ { "description": "string", "value": 0 } ],
    "netInvesting": 0,
    "financing": [ { "description": "string", "value": 0 } ],
    "netFinancing": 0,
    "netCashChange": 0,
    "beginningCash": 0,
    "endingCash": 0
  }
}
```

### GET /reports/:type/pdf
Auth required. Returns raw PDF bytes with header `Content-Type: application/pdf`.

---

## Marketplace

### GET /marketplace/advisors
No auth required.
```json
{
  "advisors": [
    {
      "id": "string", "name": "string", "photo": null,
      "experience": 15, "rating": 4.9,
      "specialization": "string", "region": "string",
      "bio": "string", "availability": "Available|Booked",
      "pricePerHour": 250
    }
  ]
}
```

### GET /marketplace/advisors/:id
Same shape as single advisor object above, plus:
```json
{
  "advisor": { ...advisor object },
  "reviews": [ { "rating": 5, "comment": "string" } ]
}
```

### POST /marketplace/book
Auth required. Request:
```json
{ "advisorId": "string", "date": "YYYY-MM-DD", "time": "HH:MM", "notes": "string" }
```
Success `201`: `{ "bookingId": "string", "message": "Booking confirmed" }`

---

## Fundraising

### GET /fundraising/readiness
Auth required.
```json
{
  "overallScore": 78,
  "financialHealth": 82,
  "breakdown": {
    "revenueGrowth": 85, "profitMargin": 72,
    "cashRunway": 78, "burnRate": 70, "unitEconomics": 82
  },
  "details": {
    "avgMonthlyRevenue": 185000, "avgMonthlyExpenses": 125000,
    "currentCash": 1245000, "monthlyBurnRate": 95000, "runwayMonths": 13
  }
}
```

### GET /fundraising/data-room
Auth required.
```json
{
  "files": [
    { "id": "string", "name": "string", "type": "pdf|xlsx|pptx|docx", "size": "2.4 MB", "updatedAt": "YYYY-MM-DD" }
  ]
}
```

---

## Notifications

### GET /notifications
Auth required.
```json
{ "notifications": [ { "id": "string", "title": "string", "message": "string", "type": "info|warning|success|error", "read": false, "createdAt": "ISO8601" } ], "unreadCount": 3 }
```

### PATCH /notifications/:id/read
Auth required. Success `200`: `{ "message": "Marked as read" }`

### POST /notifications/mark-all-read
Auth required. Success `200`: `{ "message": "All marked as read" }`

---

## Profile

### GET /profile
Auth required.
```json
{
  "user": { "id": "string", "name": "string", "email": "string", "role": "string" },
  "company": { "name": "string", "industry": "string", "monthly_revenue": 0, "monthly_expenses": 0, "employees": 0 }
}
```

### PATCH /profile
Auth required. Request: partial user or company fields.
Success `200`: `{ "message": "Profile updated", "user": { ...updated user } }`

---

## Health

### GET /health
No auth.
```json
{ "status": "ok", "timestamp": "ISO8601" }
```

---

## Error format (all errors)
```json
{ "error": "Human readable message" }
```
Never return `{ "message": ... }` for errors — always `{ "error": ... }`.
Flutter's `ApiClient._handleResponse` reads `body['error']` first.

## JWT
- Sign with `process.env.JWT_SECRET`
- Payload: `{ userId, role, email }`
- Expiry: 7 days
- Verify on every protected route via middleware

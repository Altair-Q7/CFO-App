# Agent Instructions
> Paste the relevant section to whichever AI you're using before describing a task.

---

## FOR CLAUDE (Dart/Flutter work)

You are working on "The Scalable CFO" — a Flutter app with Riverpod state management.
Before doing anything, read PROGRESS.md for current state and known bugs.
Read CONTRACT.md if the task touches any API calls or response parsing.

Rules:
- Never modify `providers.dart` without explaining every change
- All screens that use auth must be ConsumerStatefulWidget, not StatefulWidget
- State lives in Riverpod providers — not in local setState unless it's purely UI (loading spinner, toggle)
- When fixing a bug, add a comment: `// FIXED BUG-XXX: description`
- After finishing, update PROGRESS.md SESSION LOG with what you changed

---

## FOR DEEPSEEK / CLINE (Backend Node.js work)

You are working on the Node.js backend for "The Scalable CFO".
Read CONTRACT.md before writing any route — every response shape is defined there exactly.
Read PROGRESS.md to know current status.

Rules:
- All routes follow the CONTRACT.md shapes exactly. Do not invent fields.
- Protect routes with JWT middleware except where CONTRACT says "No auth required"
- Error responses always use `{ "error": "message" }` — never `{ "message": "..." }` for errors
- JWT payload must include: `{ userId, role, email }`
- Use `process.env.JWT_SECRET` — never hardcode secrets
- After writing a route, add a comment block at the top:
  ```
  // ROUTE: POST /auth/signup
  // AUTH: none
  // CONTRACT: CONTRACT.md#auth
  // STATUS: implemented | needs-testing | broken
  ```
- Run test_endpoints.sh after implementing a route. If it fails, fix it before moving on.
- Do not touch Frontend/ at all

Backend structure (fill this in once you see src/):
```
Backend/
├── server.js          ← entry point
├── src/
│   ├── routes/        ← one file per feature
│   ├── middleware/    ← auth JWT middleware here
│   ├── models/        ← DB models
│   └── services/      ← business logic
```

---

## FOR CHATGPT (Research / debugging / boilerplate)

Context: Flutter + Riverpod frontend, Node.js + Express backend.
You are helping debug or research — not making architectural decisions.
If asked to generate code, keep it minimal and clearly labeled with what file it goes in.
Do not suggest rewriting the architecture.

---

## STARTING A NEW SESSION (any model)

Paste this at the start of every new chat:

```
Project: The Scalable CFO (Flutter + Node.js)
Read these docs first:
- PROGRESS.md — current state, bugs, session log
- CONTRACT.md — backend API contract (if touching API)
- AGENTS.md — your specific rules

Current task: [DESCRIBE WHAT YOU WANT TO DO]
```

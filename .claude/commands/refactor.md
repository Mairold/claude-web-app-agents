---
model: opus
---
Standalone refactoring: baseline tests → refactor step by step → verify → deploy.

$ARGUMENTS

---

1. Run existing tests to establish green baseline:
   - Backend: `cd backend && ./gradlew test`
   - Frontend: `cd frontend && npm run build`
2. Refactor step by step — each step MUST keep tests green. Run tests after each change.
3. Run full test suite after all changes complete.
4. If E2E tests exist and UI was touched:
   - `docker compose -f docker-compose.test.yml up --build -d`
   - `cd frontend && npx playwright test`
   - `docker compose -f docker-compose.test.yml down`
5. Commit and deploy:
   - `git add` changed files by name (never `-A`)
   - `git commit -m "<short description>"`
   - `git push`
   - `docker compose up --build -d`
6. Print: `Refactoring complete and deployed`

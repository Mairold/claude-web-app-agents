---
model: opus
---
Standalone bug fix: read bug → failing test → fix → deploy → done.

Story: $ARGUMENTS

---

1. `read_story("$ARGUMENTS")` — understand the bug, reproduction steps, expected behavior
2. Analyze root cause in the codebase
3. Write a failing test that reproduces the bug
4. Fix the bug — test goes green
5. Run full test suite:
   - Backend: `cd backend && ./gradlew test`
   - Frontend: `cd frontend && npm run build`
6. If UI was involved, run E2E tests:
   - `docker compose -f docker-compose.test.yml up --build -d`
   - `cd frontend && npx playwright test`
   - `docker compose -f docker-compose.test.yml down`
7. Commit and deploy:
   - `git add` changed files by name (never `-A`)
   - `git commit -m "<short description>"`
   - `git push`
   - `docker compose up --build -d`
8. `change_status("$ARGUMENTS", "done")`
9. Print: `Bug [slug] fixed and deployed`

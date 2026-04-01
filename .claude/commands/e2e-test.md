---
model: sonnet
---
Write Playwright E2E tests for a story or feature. If Playwright is not yet set up in this project, bootstrap it first.

Story/feature to test: $ARGUMENTS

---

## Step 0 — Applicability check

Check CLAUDE.md and the project structure to determine if this is a web project (has a frontend with HTML/browser UI).

**If NOT a web project** (e.g. CLI tool, library, pure backend API without browser UI):
- Skip this entire skill. Tell the user: "This project has no browser frontend — `/e2e-test` is for web projects. Use unit/integration tests instead."
- Do NOT install Playwright or create docker-compose.test.yml.

---

## Step 0b — Bootstrap (only if Playwright is not yet configured)

Check if `playwright.config.js` (or `playwright.config.ts`) exists in the frontend directory or project root.

If NOT, set up the E2E infrastructure:

1. **Detect the tech stack** from CLAUDE.md, package.json, docker-compose.yml.

2. **Install Playwright:**
   ```
   npm install -D @playwright/test && npx playwright install chromium
   ```
   (Run in the frontend directory if separate from root.)

3. **Create `docker-compose.test.yml`** in the project root with:
   - Separate postgres (using `tmpfs` for speed, no persistent volume, NO exposed host port — backend connects via docker network)
   - Backend on a separate port (e.g. 8091) so it doesn't conflict with dev
   - Use a multi-arch Dockerfile (no `amd64/` prefix on base images) so it works on ARM (Apple Silicon) and x86
   - If the existing Dockerfile uses arch-specific images, create a `Dockerfile.test` with multi-arch equivalents

4. **Create test auth backdoor** (backend):
   - A controller/endpoint like `POST /api/auth/test-login` that creates a user + session without OAuth
   - Must be guarded so it's never active in production:
     - Spring Boot: `@ConditionalOnProperty(name = "app.test-mode", havingValue = "true")`
     - Express: middleware check for `APP_TEST_MODE` env var
   - Add the endpoint to the security config's permit-all list
   - Create an `application-test.properties` (or equivalent) that enables test mode

5. **Create `playwright.config.js`:**
   - testDir: `./e2e`
   - baseURL: `http://localhost:5174`
   - reporter: `[['html', {open: 'never'}], ['list']]` for HTML report generation
   - screenshot: `'on'` — captures final state of every test (visible in HTML report)
   - webServer: starts the frontend dev server on port 5174 pointing at test backend
   - Make the frontend proxy target configurable via env var (e.g. `VITE_API_TARGET`)

6. **Create `e2e/helpers.js`** with a `login(page, email)` and `loginAndGo(page, email, path)` function that calls the test-login endpoint.

7. **Create first smoke test** `e2e/smoke.spec.js`:
   - Unauthenticated user sees login page
   - Authenticated user sees the main page
   - Read the actual page content from failure screenshots to get the correct text/selectors

8. **Add npm scripts:**
   - `test:e2e` — runs all E2E tests headless (with env var pointing to test backend)
   - `test:e2e:ui` — interactive Playwright UI mode (best for debugging)
   - `test:e2e:report` — serves the HTML report on `0.0.0.0:8082` via `http-server` (accessible over network/Tailscale, not just localhost)

9. **Exclude E2E tests from unit test runner** (e.g. add `e2e/**` to Vitest/Jest exclude list).

10. **Add to .gitignore:** `playwright-report`, `test-results`

11. **Update CLAUDE.md** with E2E section: commands, file locations, test users, report path.

12. Run smoke tests and fix until green. Read screenshots on failure to understand actual page state.

---

## Step 1 — Understand the feature

If `$ARGUMENTS` looks like a story slug or ID, use `read_story` to understand what the feature does and what the acceptance criteria are.
If `read_story` fails (MCP unavailable), treat $ARGUMENTS as a plain description.
If it's a plain description (e.g. "image upload"), use that directly.

## Step 2 — Ensure test environment is running

Check CLAUDE.md for E2E test commands (test backend start/stop, health check URL).
1. Check if the test backend is up by hitting its health endpoint.
2. If not, start it using the command from CLAUDE.md and wait for it.

## Step 3 — Detect affected routes (diff-aware)

If `$ARGUMENTS` is a story slug or ID:
- Read the story's `## Implementation Notes` for modified files.

If no Implementation Notes exist, run:
```
git diff main --name-only
```
Map changed files to affected routes:
- `frontend/src/routes/X/` → test `/X`
- `backend/.../XController.java` → test all endpoints in that controller

Print: `Diff-aware mode: testing [N] affected routes: [list]`

## Step 4 — Write tests

Read existing E2E tests in the `e2e/` directory to understand patterns and helpers, then write tests that cover:
- Happy path (the main user flow)
- Key edge cases from the story's acceptance criteria
- Mobile viewport if the story involves responsive UI changes (use `page.setViewportSize({ width: 375, height: 812 })`)

### Conventions
- One test file per feature/story: `e2e/<feature-name>.spec.js`
- Use descriptive test names that read like user actions
- Prefer `getByRole`, `getByText`, `getByLabel` over CSS selectors
- Keep tests independent — each test logs in fresh
- Use `test.describe` to group related tests
- Use the `loginAndGo()` helper from `./helpers.js` for authentication

## Step 5 — Run and verify

Run ALL E2E tests (not just the new ones) — this is a regression check:
```
npx playwright test
```

### Find-fix-verify cycle
When a test fails:
1. Read the screenshot from `test-results/` to understand actual page state
2. Fix the issue (in code or test — but never weaken assertions)
3. Commit the fix atomically: `git commit -m "fix: <what was wrong>"`
4. Generate a regression test that would have caught this bug
5. Re-run and verify green

### Handling failures

- **New tests** (written in Step 4): Fix the underlying code or test — stay aligned with acceptance criteria. Never weaken assertions.
- **Existing tests** (were passing before): Do NOT modify them. Analyze root cause, present findings to the user, wait for approval before changing anything.

### Health score
After all tests pass, compute:
```
100 - (critical_failures × 25) - (high_failures × 10) - (warnings × 2)
```
Print: `Health score: X/100`

## Step 6 — Cleanup & Report

1. Stop the test Docker containers:
   ```
   docker compose -f docker-compose.test.yml down
   ```
2. Serve the HTML report so it's accessible over the network (not just localhost):
   ```
   npm run test:e2e:report
   ```
   If the `test:e2e:report` script doesn't exist, use `npx http-server playwright-report -p 8082 -a 0.0.0.0 --cors -c-1`.
   **Do NOT use `npx playwright show-report`** — it binds to localhost only and exits immediately in background mode.
   Tell the user the report URL using the machine's network IP and port 8082.

## Step 7 — Update story

If a story was provided, use `update_story` to append under `## Test Plan` (if MCP unavailable: print the content instead):
- E2E test file(s) created
- What flows are covered
- Health score

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
   - Separate postgres on port 5433 (using `tmpfs` for speed, no persistent volume)
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
   - `test:e2e:report` — opens the HTML report in browser

9. **Exclude E2E tests from unit test runner** (e.g. add `e2e/**` to Vitest/Jest exclude list).

10. **Add to .gitignore:** `playwright-report`, `test-results`

11. **Update CLAUDE.md** with E2E section: commands, file locations, test users, report path.

12. Run smoke tests and fix until green. Read screenshots on failure to understand actual page state.

---

## Step 1 — Understand the feature

If `$ARGUMENTS` looks like a story slug or ID, use `read_story` to understand what the feature does and what the acceptance criteria are.
If it's a plain description (e.g. "image upload"), use that directly.

## Step 2 — Ensure test environment is running

1. Check if the test backend is up (e.g. `curl -sf http://localhost:8091/api/isAuthenticated`).
2. If not, start it: `docker compose -f docker-compose.test.yml up --build -d` and wait for it.

## Step 3 — Write tests

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

## Step 4 — Run and verify

Run E2E tests. If tests fail, read the screenshot from the test-results directory to understand what the page actually looks like, then fix selectors/assertions. Iterate until green.

## Step 5 — Cleanup & Report

1. Stop the test Docker containers:
   ```
   docker compose -f docker-compose.test.yml down
   ```
2. Start the Playwright HTML report server in the background and output the URL:
   ```
   npx playwright show-report --host localhost --port 9323 &
   ```
   Then tell the user: **http://localhost:9323**

## Step 6 — Update story

If a story was provided, use `update_story` to append under `## Test Plan`:
- E2E test file(s) created
- What flows are covered

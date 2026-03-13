Write Playwright E2E tests for a story or feature. If Playwright is not yet set up in this project, bootstrap it first.

Story/feature to test: $ARGUMENTS

---

## Step 0 — Bootstrap (only if Playwright is not yet configured)

Check if `frontend/playwright.config.js` (or `playwright.config.js` / `playwright.config.ts` in the project root) exists.

If NOT, set up the E2E infrastructure:

1. **Detect the tech stack** from CLAUDE.md, package.json, docker-compose.yml.

2. **Install Playwright:**
   ```
   cd frontend && npm install -D @playwright/test && npx playwright install chromium
   ```
   (Adjust path if frontend is in root.)

3. **Create `docker-compose.test.yml`** with:
   - Separate postgres on port 5433 (using `tmpfs` for speed, no persistent volume)
   - Backend on port 8081 with `TEST_MODE=true` (or equivalent env var)
   - CORS allowing `http://localhost:5174`

4. **Create test auth backdoor** (backend):
   - A controller/endpoint like `POST /api/auth/test-login` that creates a user + session without OAuth
   - Must be guarded by an env var (`APP_TEST_MODE=true`) so it's never active in production
   - Use `@ConditionalOnProperty` (Spring Boot), middleware check (Express), or equivalent

5. **Create `playwright.config.js`:**
   - testDir: `./e2e`
   - baseURL: `http://localhost:5174`
   - webServer: starts the frontend dev server on port 5174 pointing at test backend (port 8081)

6. **Create `e2e/helpers.js`** with a `login(page, username)` function that calls the test-login endpoint.

7. **Create first smoke test** `e2e/smoke.spec.js`:
   - Unauthenticated user sees login page
   - Authenticated user sees the main page

8. **Add npm scripts:** `test:e2e` and `test:e2e:ui`

9. **Update CLAUDE.md** with E2E commands.

---

## Step 1 — Understand the feature

If `$ARGUMENTS` looks like a story slug or ID, use `read_story` to understand what the feature does and what the acceptance criteria are.
If it's a plain description (e.g. "image upload"), use that directly.

## Step 2 — Write tests

Read existing E2E tests in `e2e/` to understand patterns and helpers, then write tests that cover:
- Happy path (the main user flow)
- Key edge cases from the story's acceptance criteria
- Mobile viewport if the story involves UI changes (use `page.setViewportSize({ width: 375, height: 812 })`)

## Step 3 — Run and verify

```
cd frontend && npx playwright test <test-file>
```

The test backend must be running (`docker compose -f docker-compose.test.yml up -d`).

## Step 4 — Update story

If a story was provided, use `update_story` to append under `## Test Plan`:
- E2E test file(s) created
- What flows are covered

## Conventions
- One test file per feature/story: `e2e/<feature-name>.spec.js`
- Use descriptive test names that read like user actions
- Prefer `getByRole`, `getByText`, `getByPlaceholder` over CSS selectors
- Keep tests independent — each test logs in fresh
- Use `test.describe` to group related tests
- Use the `login()` helper from `e2e/helpers.js` for authentication

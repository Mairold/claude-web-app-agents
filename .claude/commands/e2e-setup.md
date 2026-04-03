---
model: sonnet
---
Bootstrap Playwright E2E infrastructure for this project. Run once per project.

---

## Step 1 — Detect tech stack

Read CLAUDE.md, package.json, docker-compose.yml to identify:
- Frontend framework (SvelteKit, React, etc.)
- Backend framework (Spring Boot, Express, etc.)
- Existing ports in use

## Step 2 — Install Playwright

Run in the frontend directory:
```
npm install -D @playwright/test && npx playwright install chromium
```

## Step 3 — Create `docker-compose.test.yml`

In the project root:
- Separate postgres on port 5433 (`tmpfs` for speed, no persistent volume)
- Backend on a separate port (e.g. 8091) — no conflict with dev
- Multi-arch Dockerfile (no `amd64/` prefix) — works on ARM and x86
- If existing Dockerfile uses arch-specific images, create `Dockerfile.test`

## Step 4 — Create test auth backdoor (backend)

Endpoint `POST /api/auth/test-login` — creates user + session without OAuth.
Must never be active in production:
- Spring Boot: `@ConditionalOnProperty(name = "app.test-mode", havingValue = "true")`
- Express: middleware check for `APP_TEST_MODE` env var

Add to security config permit-all list.
Create `application-test.properties` (or equivalent) that enables test mode.

## Step 5 — Create `playwright.config.js`

```js
export default {
  testDir: './e2e',
  reporter: [['html', { open: 'never' }], ['list']],
  use: {
    baseURL: 'http://localhost:5174',
    screenshot: 'on',
  },
  webServer: {
    command: 'VITE_API_TARGET=http://localhost:8091 npm run dev -- --port 5174',
    port: 5174,
    reuseExistingServer: true,
  },
}
```

## Step 6 — Create `e2e/helpers.js`

```js
export async function login(page, email) {
  await page.request.post('/api/auth/test-login', { data: { email } })
}

export async function loginAndGo(page, email, path) {
  await login(page, email)
  await page.goto(path)
}
```

## Step 7 — Create smoke test `e2e/smoke.spec.js`

- Unauthenticated user sees login page
- Authenticated user sees the main page
Read screenshots on failure to understand actual page state. Fix until green.

## Step 8 — Add npm scripts

In `frontend/package.json`:
- `test:e2e` — headless, pointing at test backend
- `test:e2e:ui` — interactive Playwright UI mode
- `test:e2e:report` — `npx http-server playwright-report -p 8082 -a 0.0.0.0 --cors -c-1`

## Step 9 — Exclude from unit test runner

Add `e2e/**` to Vitest/Jest exclude list.

## Step 10 — Update .gitignore

Add: `playwright-report`, `test-results`

## Step 11 — Update CLAUDE.md

Add `## E2E Testing` section:
- How to start test backend
- Health check URL
- Test commands
- Report URL

## Step 12 — Verify

Run smoke tests. Fix until green.
Print: `E2E infrastructure ready. Run /e2e-test <slug> to write feature tests.`

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

## Step 0b — Bootstrap check

Check if `playwright.config.js` (or `playwright.config.ts`) exists in the frontend directory or project root.

If NOT — use the Skill tool to invoke `e2e-setup`. Wait for it to complete before continuing.

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

Read ONE existing E2E test file to understand patterns and helpers (do not read all of them), then write ALL tests for this story in one go:
- Happy path only (the main user flow)
- One key edge case from acceptance criteria (pick the riskiest)
- Skip mobile viewport unless story is specifically about responsive changes

Keep it minimal — 3-5 tests max per story. More tests = more fix loops = slower.

### Conventions
- One test file per feature/story: `e2e/<feature-name>.spec.js`
- Prefer `getByRole`, `getByText`, `getByLabel` over CSS selectors
- Keep tests independent — each test logs in fresh
- Use the `loginAndGo()` helper from `./helpers.js` for authentication

## Step 5 — Run and verify

### 5a — Run NEW tests only first
```
npx playwright test e2e/<feature-name>.spec.js
```
This is fast and catches test-writing errors without waiting for the full suite.

### 5b — Fix loop (max 3 attempts)
When a test fails:
1. Read the screenshot from `test-results/`
2. Fix the issue (code or test — but never weaken assertions)
3. Re-run the failing test file only

**After 3 failed attempts on the same test:** skip it, mark as `test.skip()` with a `// TODO:` comment explaining the issue, and move on. Do not spend more time on it.

### 5c — Full regression (only after new tests pass)
```
npx playwright test
```
If an existing test breaks: do NOT modify it. Print the failure and ask the user how to proceed.

### Health score
After all runs complete, compute:
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

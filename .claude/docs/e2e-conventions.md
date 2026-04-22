# E2E Test Conventions

## Structure & Selectors

- One spec file per feature/story: `e2e/<feature-name>.spec.js`.
- **Selectors, in order:** `getByTestId` → `getByRole` / `getByLabel` → `getByText`. Use `getByText` only when the copy itself is the assertion, never as a structural anchor.
- No CSS/Tailwind-class locators, no xpath. If you need to anchor on a container, add a testid to it.
- Never assert on Tailwind classes or inline `style` — presentation, not semantics.
- Each test is independent: create its own data and log in fresh. No test may depend on another's leftover state.

## Auth

- Prefer a project-specific login helper (e.g. `loginAndGo()`) that bypasses UI flows via session cookie, over clicking through the UI each time.
- For API-only admin requests, use a shared wrapper (e.g. `adminFetch`) — never hand-roll fetch with auth headers in tests.

## Mock Layering

- **Backend-owned externals** (third-party APIs, object storage, SMS/email, queues) — mock in the backend via env vars. Single source of truth across tests.
- **Browser-loaded externals** (third-party SDKs, CDN images) — mock in Playwright via `page.route(...)` or `addInitScript`.
- **Never** intercept your own `/api/*` endpoints with `page.route`. That creates a parallel mock layer that bypasses the real handler and its backend-mocked externals.

## Test Setup via API, not SQL

- Create test data through public/admin APIs, not direct `INSERT`s. Schema changes then break the API layer loudly instead of rotting specs silently.
- Keep shared setup helpers (`createX`, `claimX`, etc.) in a fixtures file.

## When Direct SQL Is OK

- Test-hygiene DELETEs between tests (state cleanup).
- Post-action DB state assertions (verifying side effects of a UI action).
- States impossible via API (e.g. divergent cross-entity data).

## Test Isolation

- Any test that mutates shared state must clean up before setup.
- Use unique tags per test (`'<desc>-' + Date.now()`) so fixtures do not collide across runs.

## Failing Tests

- When a test fails, analyze root cause before changing test or code. Never blindly modify a test to make it pass.

## Scope

- One story = 3–5 tests max. Happy path + the riskiest edge case from the acceptance criteria. More tests = more fix loops = slower pipelines.
- One theme per `test()`. Don't mix layout + nav + form + DB side effects in a single block — split.
- When updating existing functionality, extend the existing test for that feature rather than adding a new one. Only add a new `test()` if you're covering a genuinely new behavior or risk.
- Keep each test compact. If setup + interactions + assertions don't fit on a screen, something's off — extract setup to a fixture or split.
- Skip mobile viewport tests unless the story is specifically about responsive behavior.

## Project-specific overrides

See `.claude/rules/project-e2e.md` for project-specific gotchas, helper names, mock fixture paths, and domain-model pitfalls.

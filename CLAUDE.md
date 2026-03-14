# Project Agent Configuration

## MCP Tools Available
- `list_stories` — list all stories (supports filter by status/tag)
- `read_story` — read a story by ID or slug
- `create_story` — create a new story
- `update_story` — update story description/content
- `change_status` — change story status

## Custom Commands
- `/develop <id|slug>` — full development cycle for a story (implement + review + E2E tests for UI stories)
- `/review <id|slug>` — run only the review agents on existing code
- `/e2e-test <id|slug|description>` — write Playwright E2E tests (bootstraps Playwright on first use)

## E2E Testing
`/e2e-test` bootstraps the full Playwright E2E infrastructure on first use, then writes tests for subsequent runs.
- **Bootstrap creates:** `docker-compose.test.yml`, test auth backdoor, `playwright.config.js`, `e2e/helpers.js`, smoke tests, npm scripts
- **Test auth:** `POST /api/auth/test-login` — guarded by `@ConditionalOnProperty` / env var, never active in production
- **Multi-arch:** Uses `Dockerfile.test` with arch-independent base images (works on ARM + x86)
- **`/develop` integration:** Phase 2d automatically writes E2E tests for UI stories after implementation

## Review Scope Rules
- **Only review code written/modified in the current story.** Do not flag pre-existing issues in files that were only touched for minor edits (imports, signature changes).
- **Only report CRITICAL and HIGH findings.** MEDIUM/LOW/Nice-to-have go into the story summary but do NOT generate follow-up stories or tasks.
- **Fix CRITICAL inline. Log the rest.** Never create follow-up stories from reviews. If something isn't worth fixing now, it's not worth tracking.
- **No endless cycles.** Each `/develop` run produces exactly one review round. No re-reviews, no follow-up reviews.

## Agent Roles (used internally by commands)

### Security Agent
Focuses on: hardcoded secrets, injection vectors, auth bypasses, insecure deps, sensitive data in logs.
Output format: CRITICAL / HIGH / MEDIUM / LOW findings with file:line references.

### Architecture Agent
Focuses on: God classes (>200 lines), circular deps, SOLID violations, business logic in wrong layer, naming inconsistency.
Output format: Must Fix / Should Fix / Nice to Have.

### Test Coverage Agent
Focuses on: untested public methods, happy-path-only tests, missing edge cases (null, empty, boundary), over-mocked tests, missing integration tests.
Output format: Untested Critical Paths / Weak Tests / Missing Edge Cases.

### Docs Agent
Focuses on: missing Javadoc/JSDoc on public API, undocumented REST endpoints, README gaps, non-obvious logic without comments, outdated comments.
Output format: Blocking / Important / Minor.

## Output Convention
Every agent MUST include a "Clean areas (no action needed):" section so humans know what was actually checked.

## Tech Stack
- Backend: Java / Spring Boot
- Frontend: SvelteKit
- DB: PostgreSQL
- Infra: Docker / Hetzner VPS

## Mobile Guidelines
- **No hover-only interactions.** Anything behind `hover:` must also work on touch. Use `sm:opacity-0 sm:group-hover:opacity-100` so elements are always visible on mobile but hover-revealed on desktop.
- **File inputs:** Never use `display:none` on file inputs — mobile browsers may not trigger `click()`. Use `absolute w-0 h-0 overflow-hidden opacity-0` instead.
- **Camera photos** may arrive as `image/heic`. Don't restrict file types client-side — let the backend validate.
- **Feedback:** Always show visible status (spinner, success/error message) for async actions. Mobile users can't see network tabs.
- **Tailwind breakpoints:** `sm:` = desktop-only behavior. Default (no prefix) = mobile-first.

## Clean Code Conventions
All agents and implementation must follow these rules:

- **Names & size:** Intent-revealing names. Functions ≤20 lines, 0–2 args. Single responsibility. DI.
- **Error handling:** Exceptions not return codes. No null returns — use Optional/empty collections.
- **Design:** No side effects. Command-query separation. Law of Demeter (no chaining).
- **Abstraction:** DRY but don't over-abstract. Delete dead code. Prefer well-named methods over comments. No Javadoc on private methods.
- **Tests:** Arrange-Act-Assert. One concept per test. Same quality as production code.
- **Discipline:** Boy Scout Rule. Minimal design. Only extract when clearly needed.

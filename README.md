# claude-agents

Multi-agent review setup for Claude Code. One command runs implementation + parallel security, architecture, testing, and docs review — all writing results back to your story tracker via MCP.

## Install

Run this in any project root:

```bash
curl -fsSL https://raw.githubusercontent.com/ahoa/claude-agents/master/install.sh | bash
```

The installer will:
- Copy all agent and command files into `.claude/`
- Append agent conventions to `CLAUDE.md`
- Add a `preSession` hook to `.claude/settings.json` so agents **auto-update at the start of every Claude Code session** — no manual reinstall needed when the repo changes

Restart Claude Code after the first install — files are loaded at session start.

## Usage

```
/develop <id|slug>          — implement story + auto review + E2E tests
/review <id|slug>           — review only (code already exists)
/e2e-test <id|slug|desc>    — write E2E tests (bootstraps Playwright on first use)
```

## Requirements

- Claude Code with `/agents` support
- MCP server exposing: `list_stories`, `read_story`, `create_story`, `update_story`, `change_status`

## /develop phases

| #  | Phase                | Description                                                                                                               |
|----|----------------------|---------------------------------------------------------------------------------------------------------------------------|
| 1  | Read & Plan          | Reads story via MCP. Adds acceptance criteria if missing. Documents what will be built and key assumptions.               |
| 2a | Write Tests First    | Writes unit tests before any implementation. Tests are expected to fail to compile.                                       |
| 2b | Stub Implementations | Creates empty stubs just enough to compile. All tests must be red before moving on.                                       |
| 2c | Implement            | Implements real logic one failing test at a time until all green. Refactors after green.                                  |
| 2d | E2E Tests            | Writes Playwright E2E tests for UI stories. Bootstraps Playwright on first use. Skipped for backend-only stories.        |
| 3  | Parallel Review      | Triages first — skips review for CSS-only changes. Otherwise spawns 4 independent agents simultaneously.                  |
| 4  | Fix & Synthesize     | Fixes CRITICAL/MUST FIX immediately. Writes compact summary to story. Creates follow-up story for remaining items if any. |

## /e2e-test bootstrap

On first use in a project, `/e2e-test` automatically sets up the full E2E infrastructure:

- **Playwright** — installs `@playwright/test` + Chromium
- **`docker-compose.test.yml`** — separate test DB (tmpfs) + backend on a non-conflicting port
- **Test auth backdoor** — `POST /api/auth/test-login` guarded by `@ConditionalOnProperty` (Spring) or env var check, never active in production
- **Multi-arch Dockerfile** — uses arch-independent base images so it works on both ARM (Apple Silicon) and x86
- **`playwright.config.js`** — webServer config, HTML reporter, screenshot on failure
- **`e2e/helpers.js`** — `login(page, email)` and `loginAndGo(page, email, path)` helpers
- **Smoke tests** — verifies login page + authenticated main page
- **npm scripts** — `test:e2e` (headless), `test:e2e:ui` (interactive), `test:e2e:report` (HTML report)

Subsequent runs skip bootstrap and go straight to writing tests.

## Agents

| Agent                   | Focuses on                                                                                      |
|-------------------------|-------------------------------------------------------------------------------------------------|
| `security-reviewer`     | OWASP Top 10:2025 (A01–A10) — findings tagged by category, ordered CRITICAL → LOW               |
| `architecture-reviewer` | Clean Code rules, SOLID, God classes (>200 lines), circular deps, business logic in wrong layer |
| `test-reviewer`         | Untested critical paths, happy-path-only tests, missing edge cases, over-mocked tests           |
| `docs-reviewer`         | Missing README, undocumented endpoints, unexplained business logic, outdated comments           |

Each agent runs in its own clean context — it sees only the file paths it was given and its own system prompt. No shared state between agents.

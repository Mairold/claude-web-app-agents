# claude-agents

Multi-agent review + development orchestration for Claude Code. Composable skills that chain into a full cycle: plan → implement → test → review → fix → deploy. Story state managed via MCP.

## Install

Run this in any project root in Hezner build machine:

```bash
curl -fsSL https://raw.githubusercontent.com/ahoa/claude-agents/master/install.sh | bash
```


The installer will:
- Copy all agent and command files into `.claude/`
- Append agent conventions to `CLAUDE.md`
- Add a `SessionStart` hook to `.claude/settings.json` so agents **auto-update at the start of every Claude Code session**

Restart Claude Code after the first install — files are loaded at session start.

## Commands

```
/develop <slug>       — full cycle: plan → implement → test → review → fix → deploy
/plan <slug>          — read story, add AC + plan
/implement <slug>     — TDD implementation
/e2e-test <slug>      — Playwright E2E tests
/review <slug>        — parallel review (up to 6 agents)
/fix-and-ship <slug>  — fix CRITICAL/MUST FIX + close story
/fix-bug <slug>       — standalone: read bug → test → fix → deploy → done
/refactor             — standalone: baseline → refactor → verify → deploy
```

## Requirements

- Claude Code with `/agents` support
- MCP server exposing: `list_stories`, `read_story`, `create_story`, `update_story`, `change_status`

## /develop phases

| # | Phase           | Skill           | MCP tools                    |
|---|-----------------|-----------------|------------------------------|
| 1 | Plan            | `/plan`         | `read_story`, `update_story` |
| 2 | Implement       | `/implement`    | `update_story` (tasks [x])   |
| 3 | E2E Tests       | `/e2e-test`     | `update_story` (test plan)   |
| 4 | Review          | `/review`       | —                            |
| 5 | Fix & Ship      | `/fix-and-ship` | `change_status`              |
| 6 | Commit & Deploy | inline          | —                            |

## /e2e-test bootstrap

On first use in a project, `/e2e-test` automatically sets up the full E2E infrastructure:

- **Playwright** — installs `@playwright/test` + Chromium
- **`docker-compose.test.yml`** — separate test DB (tmpfs) + backend on a non-conflicting port
- **Test auth backdoor** — `POST /api/auth/test-login` guarded by `@ConditionalOnProperty` (Spring) or env var check, never active in production
- **Multi-arch Dockerfile** — uses arch-independent base images so it works on both ARM (Apple Silicon) and x86
- **`playwright.config.js`** — webServer config, HTML reporter, screenshot on every test
- **`e2e/helpers.js`** — `login(page, email)` and `loginAndGo(page, email, path)` helpers
- **Smoke tests** — verifies login page + authenticated main page
- **npm scripts** — `test:e2e` (headless), `test:e2e:ui` (interactive), `test:e2e:report` (HTML report)

Subsequent runs skip bootstrap and go straight to writing tests.

## Agents and model assignment

| Agent/Command           | Model  | Reason                                            |
|-------------------------|--------|---------------------------------------------------|
| **Agents**              |        |                                                   |
| `security-reviewer`     | sonnet | Pattern matching against OWASP checklist          |
| `architecture-reviewer` | sonnet | Pattern matching against SOLID/Clean Code rules   |
| `test-reviewer`         | sonnet | Cross-referencing src/ vs test/ coverage          |
| `docs-reviewer`         | haiku  | Simple documentation completeness check           |
| `svelte-reviewer`       | sonnet | Framework-specific pattern check                  |
| `spring-reviewer`       | sonnet | Framework-specific pattern check                  |
| **Commands**            |        |                                                   |
| `/develop`              | opus   | Orchestrator — runs /implement inline, needs opus |
| `/plan`                 | sonnet | Story reading + AC generation is straightforward  |
| `/implement`            | opus   | Code generation requires strongest model          |
| `/e2e-test`             | sonnet | Test writing follows established patterns         |
| `/review`               | sonnet | Spawns agents, no code generation                 |
| `/fix-and-ship`         | sonnet | Mechanical: fix + status change                   |
| `/fix-bug`              | opus   | Root cause analysis requires deep reasoning       |
| `/refactor`             | opus   | Code changes must preserve correctness            |

### Why this split

`/develop` chains sub-skills via the Skill tool (inline expansion). This means all phases within `/develop` run as **opus** regardless of the sub-skill's own model frontmatter. The sub-skill model only applies to standalone invocation (e.g. `/plan slug` directly).

This is the right tradeoff:
- **Implementation dominates token usage (~60%)** — it needs opus anyway
- **Context preservation between phases is more valuable** than saving sonnet vs opus cost on plan/review
- **Review agents are spawned via Agent tool** — they DO get their own model (sonnet/haiku), so the optimization works there

Each agent runs in its own clean context — it sees only the file paths it was given and its own system prompt. No shared state between agents.

### Verbosity constraints

All agents: max 30 lines output, max 3 lines per finding. Commands: one status line per phase.

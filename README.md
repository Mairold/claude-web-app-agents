# claude-agents

Multi-agent review + development orchestration for Claude Code. Composable skills that chain into a full cycle: plan → implement → test → review → fix → deploy. Story state managed via MCP.

## Install

Run this in any project root in Hezner build machine:

```bash
curl -fsSL https://raw.githubusercontent.com/ahoa/claude-agents/master/install.sh | bash
```


The installer will:
- Copy 11 agents (8 review + 3 TDD), 11 commands, 3 skills, and 5 rules into `.claude/`
- Copy shared config to `.claude/rules/shared-config.md` (auto-loaded by Claude Code)
- Never modifies your project `CLAUDE.md` — it stays yours
- Add a `SessionStart` hook to `.claude/settings.json` so agents **auto-update at the start of every Claude Code session**

Restart Claude Code after the first install — files are loaded at session start.

## Commands

```
/develop <slug>       — full cycle: plan → implement → test → review → fix → deploy
/plan <slug>          — read story, add AC + plan
/implement <slug>     — TDD implementation
/e2e-test <slug>      — Playwright E2E tests
/review <slug>        — parallel review (up to 8 agents)
/ship <slug>          — commit, deploy, close story
/fix-bug <slug>       — standalone: read bug → test → fix → deploy → done
/refactor             — standalone: baseline → refactor → verify → deploy
/retro                — analyze accumulated learnings, propose rule promotions
/learn <desc|uuid>    — manually log or promote a learning
```

## Requirements

- Claude Code with `/agents` support
- MCP server exposing: `list_stories`, `read_story`, `create_story`, `update_story`, `change_status`, `log_learning`, `list_learnings`, `promote_learning`

## /develop phases

| # | Phase           | Skill           | MCP tools                    |
|---|-----------------|-----------------|------------------------------|
| 1 | Plan            | `/plan`         | `read_story`, `update_story` |
| 2 | Implement       | `/implement`    | `update_story` (tasks [x]) — spawns TDD agents |
| 3 | E2E Tests       | `/e2e-test`     | `update_story` (test plan)   |
| 4 | Review          | `/review`       | —                            |
| 5 | Ship            | `/ship`         | `change_status`              |

## Project configuration

On first run, `/review` and `/ship` ask how your project works and save the answers to your CLAUDE.md. After that, they use the saved config automatically.

### Review config (`## Review` in CLAUDE.md)

```yaml
review_fix: auto        # auto — fix CRITICAL/HIGH immediately
                        # ask  — show each fix, wait for approval
followup: create        # create — bundle MEDIUM into follow-up story
                        # skip   — print summary only, no follow-up
```

### Ship config (`## Ship` in CLAUDE.md)

```yaml
deploy: docker compose up --build -d   # or: fly deploy, vercel --prod, skip
post_deploy: docker compose logs backend --tail 20   # or: curl health URL, empty
url: auto                              # auto — detect from docker/output
                                       # or explicit: https://app.example.com
```

`deploy: skip` — no deploy, just commit and mark done (e.g. Node projects without local deploy).

## Custom rules

Claude Code auto-loads every `.md` file under `.claude/rules/` at session start. **No need to edit your project `CLAUDE.md`** — drop a file in `.claude/rules/` and it's active on next session.

### How rule files are loaded

| File pattern                        | When it loads                                     | Overwritten on update? |
|-------------------------------------|---------------------------------------------------|------------------------|
| `shared-config.md`                  | Every session, unconditionally                    | Yes — shared across all projects |
| `java-best-practices.md`, etc.      | Only when matching files are opened (see `paths:`) | Yes — language conventions |
| `project-*.md`                      | Every session, unconditionally                    | **No — yours to own**  |
| Any other `*.md` you drop in        | Every session, unconditionally                    | No — installer ignores |

### Writing project-specific rules

The installer creates `.claude/rules/project-security.md` once (empty template). Fill it with rules that are **unique to this project** — not generic OWASP or Spring best practices (those are already loaded).

**Good project-specific rules** (go in `project-security.md`):

```markdown
# Project-specific security rules

- All admin endpoints require `@PreAuthorize("hasRole('ADMIN')")`
- PII fields (ssn, dob, phone) must be encrypted at rest with KMS key `pii-v2`
- Webhooks from Stripe must verify HMAC signature using secret in `STRIPE_WEBHOOK_SECRET`
- Test-login endpoint allowed only when env `TEST_LOGIN_ENABLED=true` (never in prod)
```

**What does NOT belong here** (already covered automatically):

- OWASP Top 10 checklist → `security-reviewer` has this inline
- Generic crypto advice ("don't use MD5") → `.claude/docs/security-conventions.md`
- Language/framework conventions → `java-best-practices.md`, `spring-conventions.md`, etc.

### Overriding shared conventions

When a shared doc says one thing and your project needs an exception, **never edit `.claude/docs/*.md` directly** — the installer overwrites those on every update. Instead, write the override in `.claude/rules/project-*.md`.

**Precedence (most specific wins):**

1. `.claude/rules/project-*.md` — your project rules (never overwritten)
2. `.claude/docs/*.md` — shared baseline (auto-updated by installer)
3. Agent inline checklist (e.g. OWASP Top 10 in `security-reviewer`)

**Example** — single-admin backoffice exempts IDOR checks.

Baseline (`.claude/docs/security-conventions.md` — auto-updated, keep untouched):

```markdown
## IDOR Protection
- All entity operations must verify ownership before exposing data
```

Project override (`.claude/rules/project-security.md` — yours to own):

```markdown
## Override: IDOR Protection
- Single-admin backoffice — all authenticated users are trusted
- Do NOT flag IDOR on backoffice endpoints
- Revisit all endpoints if multi-user support is added
```

Agents that read project rules (currently `security-reviewer`) honor the override — the exemption wins over the OWASP checklist. To extend this to other reviewers (spring, architecture, etc.), add the same *"read `.claude/rules/project-*.md` first, project rules override"* pattern to the agent file.

### Adding rules for other domains

Drop any `.md` file into `.claude/rules/`. It loads on next session. Name with `project-` prefix to prevent the installer from ever overwriting it.

```bash
# Payments domain rules — never overwritten
cat > .claude/rules/project-payments.md <<'EOF'
# Payment module rules

- All money amounts use BigDecimal, never double/float
- Every charge must have an idempotency key from the client
- Refunds > $500 require 2-person approval flag
EOF
```

### Scoping a rule to specific files

Add `paths:` frontmatter so the rule loads only when matching files are opened. Useful when the rule is noise in unrelated contexts:

```markdown
---
paths: "**/*.java"
---
# Java-only rules...
```

Files **without** `paths:` load unconditionally. Use `paths:` for language/framework rules (Java, Swift, TypeScript). Leave it off for cross-cutting conventions (security, business rules, domain policies).

### Shared config

`shared-config.md` is auto-updated by the installer and auto-loaded by Claude Code. It holds MCP tool list, command list, story-sizing rules, review-scope rules, and pointers to `.claude/docs/`. Your project `CLAUDE.md` stays untouched.

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
| `swift-reviewer`        | sonnet | Swift memory, concurrency, security checks        |
| `swiftui-reviewer`      | sonnet | SwiftUI property wrappers, perf, accessibility    |
| **TDD Agents**          |        |                                                   |
| `tdd-test-writer`       | sonnet | RED phase — writes failing tests only             |
| `tdd-implementer`       | opus   | GREEN phase — makes tests pass one at a time      |
| `tdd-refactorer`        | sonnet | REFACTOR phase — improves code, tests stay green  |
| **Commands**            |        |                                                   |
| `/develop`              | opus   | Orchestrator — runs /implement inline, needs opus |
| `/plan`                 | sonnet | Story reading + AC generation is straightforward  |
| `/implement`            | opus   | Code generation requires strongest model          |
| `/e2e-test`             | sonnet | Test writing follows established patterns         |
| `/review`               | sonnet | Spawns agents, no code generation                 |
| `/ship`                 | sonnet | Commit + deploy from CLAUDE.md config              |
| `/fix-bug`              | opus   | Root cause analysis requires deep reasoning       |
| `/refactor`             | opus   | Code changes must preserve correctness            |
| `/retro`                | sonnet | Pattern analysis, text generation                 |
| `/learn`                | sonnet | Simple log or promote operation                   |

### Why this split

`/develop` chains sub-skills via the Skill tool (inline expansion). This means all phases within `/develop` run as **opus** regardless of the sub-skill's own model frontmatter. The sub-skill model only applies to standalone invocation (e.g. `/plan slug` directly).

This is the right tradeoff:
- **Implementation dominates token usage (~60%)** — it needs opus anyway
- **Context preservation between phases is more valuable** than saving sonnet vs opus cost on plan/review
- **Review agents are spawned via Agent tool** — they DO get their own model (sonnet/haiku), so the optimization works there

Each agent runs in its own clean context — it sees only the file paths it was given and its own system prompt. No shared state between agents.

### Swift / iOS support

Swift and SwiftUI files (`.swift`) activate:
- **`swift-reviewer`** — memory safety, concurrency, force operations, Keychain security, SwiftLint
- **`swiftui-reviewer`** — property wrapper misuse, performance anti-patterns, accessibility, navigation
- **Rules** — `swift-best-practices.md` and `swift-naming.md` auto-activate for `**/*.swift`
- **Skill** — `swiftui` skill auto-invokes for SwiftUI views, MVVM, Combine, property wrappers

## Learnings

Review findings (HIGH/CRITICAL) are automatically logged via `log_learning` after each `/review` or `/develop` run. Over time, patterns accumulate.

- **`/retro`** — analyzes accumulated learnings, finds recurring patterns (3+ occurrences per project, 5+ cross-project), and proposes exact rule additions to CLAUDE.md or agent files. You confirm each promotion individually.
- **`/learn <description>`** — manually log a learning from any context (debugging session, production incident, etc.)
- **`/learn <uuid>`** — promote a specific learning to a permanent rule in CLAUDE.md or agent files

Requires MCP server with `log_learning`, `list_learnings`, `promote_learning` endpoints.

### Verbosity constraints

All agents: max 30 lines output, max 3 lines per finding. Commands: one status line per phase.

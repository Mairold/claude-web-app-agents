---
model: sonnet
---
Run review agents against implemented code. Conditionally includes tech-stack agents.

Story: $ARGUMENTS

---

## Step 1 — Determine scope

**Full codebase review:** If `$ARGUMENTS` contains "all", "kogu", "full", or "codebase" — review all source files (find by file type: .java, .svelte, .ts, .js, .swift etc). Skip triage. Print: `Full codebase review`. Note: "only review current story code" rule does NOT apply to full reviews.

**Story review (default):**
1. `read_story("$ARGUMENTS")` or use `git diff main --name-only` to find modified files. If MCP unavailable, use git diff directly.
2. If no file list found, ask the user which paths to review.
3. **Triage:** If ALL files are CSS-only, Tailwind class changes, or SVG icon components — skip review entirely. Print: `Review skipped (trivial change)`.

## Step 2 — Select and spawn agents
Determine which agents to run based on modified file types:

**Always run (3 core agents):**
- `security-reviewer` (model: sonnet)
- `architecture-reviewer` (model: sonnet)
- `test-reviewer` (model: sonnet)

**Conditionally run:**
- If new/changed public HTTP API endpoints, or changes that alter README setup/env/run commands: add `docs-reviewer` (model: haiku). Do NOT add for internal refactors or touches to an existing endpoint's internals.
- If `.svelte`, `.js`, `.ts` files in `frontend/`: add `svelte-reviewer` (model: sonnet)
- If `.java` files in `backend/`: add `spring-reviewer` (model: sonnet)
- If `.swift` files modified: add `swift-reviewer` (model: sonnet) + `swiftui-reviewer` (model: sonnet)

Spawn ALL selected agents in parallel using the Agent tool. Pass each agent:
> Analyze these files: [MODIFIED_FILES]. Only review code written/modified in this story, not pre-existing issues. Return a single JSON object matching the agent's Output Format schema — no preamble, no markdown.

## Step 3 — Synthesize

Each agent returns a JSON object with `findings`, `clean_areas`, `summary`.
Parse each agent's output as JSON. Count findings per severity.

Print a compact summary table:

```
| Agent | Findings | Critical | High | Medium |
|-------|----------|----------|------|--------|
| Security | 3 | 1 | 2 | 0 |
| Architecture | 1 | 0 | 1 | 0 |
| Spring | 0 (clean) | 0 | 0 | 0 |
```

Then print CRITICAL and HIGH findings with `title` + `location`:

```
**CRITICAL:**
- [security] A04 — Hardcoded DB password (DbConfig.java:12)

**HIGH:**
- [security] A05 — SQL injection risk in search query (UserRepo.java:88)
- [architecture] Circular dependency: Service A → B → A (ServiceA.java:15)
```

Clean areas (one line, joined from each agent's `clean_areas`): `Security: input validation, CSRF. Architecture: SOLID. Spring: DI patterns.`

If an agent's output is not valid JSON:
- Print: `⚠️ [agent-name] returned invalid JSON — skipping`
- Continue with other agents' findings

Do NOT write review findings into the story — stories are for the user, not internal review data.
**One review round per `/develop` run.** No re-reviews, no follow-up reviews.

## Step 4 — Fix findings (MANDATORY config check)

Read CLAUDE.md and look for a `## Review` section with `review_fix:` and `followup:` values.

**If the section is missing or any value is missing: STOP and ask the user. Do NOT proceed with fixes. Do NOT guess or use defaults.**

Ask:
1. "How to handle CRITICAL/HIGH findings? `auto` (fix immediately) or `ask` (show each fix, wait for approval)?"
2. "How to handle MEDIUM findings? `create` (bundle into follow-up story) or `skip` (print summary only)?"

After user answers, write the `## Review` section to CLAUDE.md with their answers, then continue.

Then apply:
- **CRITICAL + HIGH:** if `review_fix: auto` → fix inline. If `review_fix: ask` → show each proposed fix, wait for user approval per fix.
- **MEDIUM:** if `followup: create` → collect all into ONE follow-up story (`[FOLLOWUP] <slug> — review cleanup`). If `followup: skip` → print summary only.
- **LOW:** ignore entirely.

If any code was changed, re-run E2E tests:
- `docker compose -f docker-compose.test.yml up --build -d`
- `npx playwright test`
- `docker compose -f docker-compose.test.yml down`

## Step 5 — Log learnings

For each finding with `severity` of `critical` or `high` from Step 3:

```
log_learning(
  project=<project name from CLAUDE.md>,
  story_slug=$ARGUMENTS,
  phase="review",
  category=finding.category,
  agent=<agent that returned it>,
  severity=finding.severity,
  finding=finding.title
)
```

No text parsing needed — `category`, `severity`, and `finding` come directly from the agent's JSON output. One `log_learning` call per finding.

If MCP unavailable: skip silently, print `[learnings not logged]`, never block review output.

## Step 6 — Output metrics for /develop

On the very last line of review output, print exactly:

```
OUTPUT_METRICS: findings_critical=<N> findings_high=<N> findings_medium=<N>
```

`/develop` parses this line to call `log_metric` for the review phase.

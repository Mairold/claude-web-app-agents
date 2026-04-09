---
model: sonnet
---
Run review agents against implemented code. Conditionally includes tech-stack agents.

Story: $ARGUMENTS

---

## Step 1 — Determine scope
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
- If new API endpoints, public-facing changes, or README-affecting scope: add `docs-reviewer` (model: haiku)
- If `.svelte`, `.js`, `.ts` files in `frontend/`: add `svelte-reviewer` (model: sonnet)
- If `.java` files in `backend/`: add `spring-reviewer` (model: sonnet)
- If `.swift` files modified: add `swift-reviewer` (model: sonnet) + `swiftui-reviewer` (model: sonnet)

Spawn ALL selected agents in parallel using the Agent tool. Pass each agent:
> Analyze these files: [MODIFIED_FILES]. Only review code written/modified in this story, not pre-existing issues. Return your findings as structured text.

## Step 3 — Synthesize
Collect all outputs. Print compact summary table (one line per agent, skip agents with no findings):
```
| Agent | Findings |
|-------|----------|
| Security | 1 HIGH: missing auth check on new endpoint |
| Spring | Clean |
```

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

## Step 4 — Log learnings

After synthesis, log HIGH and CRITICAL findings via `log_learning`.
Read project name from CLAUDE.md (first line after `#` or `project:` field).

For each HIGH or CRITICAL finding from Step 3:
- phase: "review"
- category: map agent to category:
    security-reviewer    → "security"
    architecture-reviewer → "architecture"
    test-reviewer        → "testing"
    docs-reviewer        → "docs"
    svelte-reviewer      → "svelte"
    spring-reviewer      → "spring"
    swift-reviewer       → "swift"
    swiftui-reviewer     → "swift"
- agent: the agent name that found it
- severity: "critical" or "high"
- finding: one sentence — what the problem is (no file paths, no line numbers)
- story_slug: $ARGUMENTS

Call `log_learning` once per distinct finding.
If MCP unavailable: skip silently, print `[learnings not logged]`, never block review output.

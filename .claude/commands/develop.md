---
model: opus
---
Full development cycle: plan, implement, test, review, ship.

Story: $ARGUMENTS

---

Execute each phase in order. One line status after each phase.

## Context management
Each phase MUST output only a one-line status + timing. Do NOT repeat or summarize outputs from previous phases. If context is getting large, discard details from earlier phases — only the file list from implement matters for review.

## Timing
Before each phase, run `date +%s` and store the result. After each phase completes, run `date +%s` again and calculate duration. Print duration after each phase status line in format: `(Xm Ys)`.

At the very start, run `date +%s` and store as `DEVELOP_START`.

## Project + counters (for log_metric)
- Read project name from CLAUDE.md (first `# <name>` heading or `project:` YAML field) — use as `project` in every `log_metric` call.
- Initialize `HUMAN_INTERVENTIONS=0`. Increment every time this /develop run itself prompts the user — `AskUserQuestion`, mandatory-config STOPs, `review_fix: ask` approvals, deploy confirmations. Do NOT count prompts issued by subagents.
- Sub-skills emit `OUTPUT_METRICS: key=value ...` on their final line. Parse the last `OUTPUT_METRICS:` line of each sub-skill output; missing fields default to null.
- If a phase is skipped, do NOT call `log_metric` for that phase.
- MCP fallback: if `log_metric` fails or MCP is unavailable, print `[metric not saved]` and continue. Never block the pipeline.

## Phase 0 — Read develop config (MANDATORY)

Read CLAUDE.md and look for a `## Develop` section with a `mode:` value.

**If the section is missing or the value is missing: STOP and ask the user. Do NOT proceed. Do NOT guess or use defaults.**

Ask:
1. "What mode? `proto` (prototype — skip E2E tests for faster iteration) or `full` (complete flow with E2E)?"

After the user answers, write the `## Develop` section to CLAUDE.md with their answer, then continue.

Remember the `mode` value — Phase 3 uses it.

## Phase 1 — Plan
Use the Skill tool to invoke `plan` with args "$ARGUMENTS".

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="plan",
           duration_seconds=<phase duration>, outcome="success" | "failed")
```

## Phase 2 — Implement
Use the Skill tool to invoke `implement` with args "$ARGUMENTS".

Parse `OUTPUT_METRICS: tests_total=N tests_first_try=true|false` from implement's output.

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="implement",
           duration_seconds=<phase duration>, outcome="success" | "failed",
           tests_total=<parsed>, tests_first_try=<parsed>)
```

## Phase 3 — E2E Tests

**If `mode: proto` (from Phase 0): skip E2E entirely.** Print: `E2E skipped (proto mode)` — no log_metric call.

Otherwise, run E2E tests if ANY of these are true:
- UI files (.svelte, frontend .js/.ts, CSS) were modified
- More than 3 backend files were changed
- API endpoints, return types, or security config changed
- Story is labeled "security" or "architecture"

**If yes:** Use the Skill tool to invoke `e2e-test` with args "$ARGUMENTS".
**Skip only for:** isolated single-file fixes, test-only changes, docs. Print: `E2E skipped (isolated change)` — no log_metric call.

If E2E ran, parse `OUTPUT_METRICS: tests_total=N tests_first_try=true|false`:

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="e2e",
           duration_seconds=<phase duration>, outcome="success" | "failed",
           tests_total=<parsed>, tests_first_try=<parsed>)
```

## Phase 4 — Review
**Triage first:** If ALL modified files are CSS-only, Tailwind classes, or SVG icon components — skip review. Print: `Review skipped (trivial change)` — no log_metric call.

Otherwise: Use the Skill tool to invoke `review` with args "$ARGUMENTS".

Parse `OUTPUT_METRICS: findings_critical=N findings_high=N findings_medium=N` from review's output. Remember these counts — the overall metric at Done reuses them.

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="review",
           duration_seconds=<phase duration>, outcome="success" | "failed",
           findings_critical=<parsed>, findings_high=<parsed>, findings_medium=<parsed>)
```

## Phase 5 — Ship
Use the Skill tool to invoke `ship` with args "$ARGUMENTS".

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="ship",
           duration_seconds=<phase duration>, outcome="success" | "failed")
```

## Done
Calculate total duration from `DEVELOP_START`. Print timing summary:
```
[slug] done | Tests: X unit, X E2E

Timing:
  Plan:       Xm Ys
  Implement:  Xm Ys
  E2E Tests:  Xm Ys (or "skipped")
  Review:     Xm Ys (or "skipped")
  Ship:       Xm Ys
  Total:      Xm Ys
```

Log the overall metric (uses `findings_*` counts remembered from Phase 4):

```
log_metric(project=<project>, story_slug=$ARGUMENTS, phase="develop",
           duration_seconds=<total>, outcome="success" | "failed" | "aborted",
           findings_critical=<review sum>, findings_high=<review sum>,
           findings_medium=<review sum>, human_interventions=HUMAN_INTERVENTIONS)
```

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

## Phase 1 — Plan
Use the Skill tool to invoke `plan` with args `"--from-develop $ARGUMENTS"`.

## Phase 2 — Implement
Use the Skill tool to invoke `implement` with args "$ARGUMENTS".

## Phase 3 — E2E Tests
Run E2E tests if ANY of these are true:
- UI files (.svelte, frontend .js/.ts, CSS) were modified
- More than 3 backend files were changed
- API endpoints, return types, or security config changed
- Story is labeled "security" or "architecture"

**If yes:** Use the Skill tool to invoke `e2e-test` with args "$ARGUMENTS".
**Skip only for:** isolated single-file fixes, test-only changes, docs. Print: `E2E skipped (isolated change)`

## Phase 4 — Review
**Triage first:** If ALL modified files are CSS-only, Tailwind classes, or SVG icon components — skip review. Print: `Review skipped (trivial change)`.

Otherwise: Use the Skill tool to invoke `review` with args "$ARGUMENTS".

## Phase 5 — Ship
Use the Skill tool to invoke `ship` with args "$ARGUMENTS".

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

---
model: opus
---
Full development cycle: plan, implement, test, review, fix, commit, push, deploy.

Story: $ARGUMENTS

---

Execute each phase in order. One line status after each phase.

## Timing
Before each phase, run `date +%s` and store the result. After each phase completes, run `date +%s` again and calculate duration. Print duration after each phase status line in format: `(Xm Ys)`.

At the very start, run `date +%s` and store as `DEVELOP_START`.

## Phase 1 — Plan
Use the Skill tool to invoke `plan` with args "$ARGUMENTS".

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
This triage does NOT apply to Phase 3 (E2E tests must always run for UI changes).

Otherwise: Use the Skill tool to invoke `review` with args "$ARGUMENTS".

## Phase 5 — Fix & Ship
Use the Skill tool to invoke `fix-and-ship` with args "--from-develop $ARGUMENTS".

## Phase 6 — Commit & Deploy
1. Restore any docs/ changes: `git restore --staged docs/ 2>/dev/null; git checkout -- docs/ 2>/dev/null`
2. `git add` modified files by name (never `git add -A`)
3. `git commit -m "<short description>"`
4. `git push`
5. `docker compose up --build -d`
6. Wait 10s, check `docker compose logs backend --tail 20` for startup errors

## Done
Calculate total duration from `DEVELOP_START`. Print timing summary:
```
[slug] done | Tests: X unit, X E2E

⏱ Timing:
  Plan:       Xm Ys
  Implement:  Xm Ys
  E2E Tests:  Xm Ys (or "skipped")
  Review:     Xm Ys (or "skipped")
  Fix & Ship: Xm Ys
  Deploy:     Xm Ys
  ─────────────────
  Total:      Xm Ys
```

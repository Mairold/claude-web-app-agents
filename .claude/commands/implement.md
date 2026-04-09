---
model: opus
---
Implement a story using TDD. Work through tasks, mark completed.

Story: $ARGUMENTS

---

Completeness Principle: when the marginal cost of full implementation
is near-zero, always implement the complete version. The delta between
80 lines and 150 lines is meaningless. Do not suggest shortcuts.

Tests are part of every task — always write tests with every task, not as a separate step.

1. `read_story("$ARGUMENTS")` — get tasks and acceptance criteria
   (If MCP unavailable: use $ARGUMENTS as description if it has spaces, else ask user to paste requirements.)

2. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): skip TDD scaffolding (steps 3a-3b), implement tasks directly, verify tests pass after each.

3. **Regular stories — TDD cycle (isolated phases):**

   a. **RED — spawn `tdd-test-writer` agent (run_in_background: false):**
      Pass: story slug, requirements from read_story, interface specification.
      Gate: do NOT proceed until agent prints `RED phase complete`.
      Verify: test files exist and tests fail to compile or fail at runtime.
      **After gate:** print only file names created. Do NOT copy agent output into conversation.

   b. **Dedup check:** Before spawning tdd-implementer, search for existing
      methods/utilities that already do the same thing. Pass findings to the
      implementer: "Reuse or extend — never duplicate."

   c. **GREEN — spawn `tdd-implementer` agent:**
      Pass: list of failing test files from phase a + dedup findings from phase b.
      Gate: do NOT proceed until agent prints `GREEN phase complete`.
      Verify: `cd backend && ./gradlew test` — all tests pass.
      **After gate:** print only file count and pass/fail. Do NOT copy agent output into conversation.

   d. **REFACTOR (conditional) — skip if fewer than 5 files were modified in phase c.**
      If skipped, print: `REFACTOR skipped (small change)`
      Otherwise, spawn `tdd-refactorer` agent:
      Pass: list of implementation files modified in phase c.
      Gate: do NOT proceed until agent prints `REFACTOR phase complete`.
      Verify: tests still all pass.
      **After gate:** print only pass/fail. Do NOT copy agent output into conversation.

4. Mark completed tasks: `update_story` with `- [x]` for each done task (if MCP unavailable: print completed tasks)
   Follow MCP Safety Rules from `agent_docs/mcp-rules.md`.

5. Verify:
   - Backend: `cd backend && ./gradlew test`
   - Frontend: `cd frontend && npm run build`

6. Track the list of all files created/modified — needed for review phase.

7. Print a compact summary ONLY — do not repeat agent outputs:
```
Implementation done for [slug]
Files: [list of created/modified files, one per line]
Tests: [N] passing
```
Do NOT echo back full agent outputs. The summary above is the only output needed for the next phase.

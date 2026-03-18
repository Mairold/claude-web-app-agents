---
model: opus
---
Implement a story using TDD. Work through tasks, mark completed.

Story: $ARGUMENTS

---

Completeness Principle: when the marginal cost of full implementation 
is near-zero, always implement the complete version. The delta between 
80 lines and 150 lines is meaningless. Do not suggest shortcuts.

1. `read_story("$ARGUMENTS")` — get tasks and acceptance criteria

2. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): skip TDD scaffolding (steps 3a-3b), implement tasks directly, verify tests pass after each.

3. **Regular stories — TDD cycle:**
   a. **Tests first:** Write unit tests for every non-trivial function. Cover: happy path, null/empty, boundary, error cases. Arrange-Act-Assert, one concept per test. Tests will fail to compile — that's correct.
   b. **Stubs:** Create empty implementations so tests compile. Methods return null/Optional.empty()/throw UnsupportedOperationException. All tests should compile and fail (red).
   c. **Implement:** One failing test at a time. No code without a failing test. Refactor after green (Boy Scout Rule).

4. Mark completed tasks: `update_story` with `- [x]` for each done task

5. Verify:
   - Backend: `cd backend && ./gradlew test`
   - Frontend: `cd frontend && npm run build`

6. Track the list of all files created/modified — needed for review phase.

7. Print: `Implementation done for [slug]`

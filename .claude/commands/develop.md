You are a development orchestrator. Implement a story fully using TDD, then validate with parallel review agents.

Story to develop: $ARGUMENTS

---

## Phase 1 — Read & Plan

1. Use `read_story` with "$ARGUMENTS" (works with both ID and slug).
2. Understand requirements fully. State assumptions clearly — do not ask, document them.
3. Use `update_story` to append under `## Details`:
   - Implementation plan: what you will build, files to create or modify, assumptions made

---

## Phase 2a — Write Tests First

⚠️ DO NOT write any implementation code yet. Tests come first, always.

4. For every non-trivial class or function in your plan, write the unit tests first:
   - Test file structure and class names based on the plan
   - Cover: happy path, null/empty input, boundary values, error cases
   - Tests must follow Arrange-Act-Assert. One concept per test.
   - Tests will fail to compile — that is expected and correct at this stage.

5. Use `update_story` to append `## Test Plan` with the list of test files created.

---

## Phase 2b — Stub Implementations

⚠️ DO NOT implement real logic yet.

6. Create empty/stub implementations just enough to make the code compile:
   - Methods return `null`, `Optional.empty()`, or throw `UnsupportedOperationException`
   - All tests should now compile and **fail** (red). Verify this before moving on.

---

## Phase 2c — Implement

7. Implement the actual logic, following CLAUDE.md conventions, until all tests pass (green).
   - Work through one failing test at a time
   - Do not write code that isn't required by a failing test
   - Refactor after green — clean up without breaking tests (Boy Scout Rule)

8. Use `update_story` to append `## Implementation Notes` with:
   - What was built and key decisions made
   - **Exact list of files created/modified** (passed to review agents)
   - Update `## Tasks` checkboxes to `- [x]` as each task is completed

---

## Phase 3 — Parallel Review

9. Use `create_story` for each review role with this title format:
   `# Feature: [REVIEW][role] <original story title> — <today's date>`
   Add tag "review-batch". Note each returned ID.
   Roles: security, architecture, testing, docs

10. Spawn all 4 Tasks simultaneously — agents are fully independent and must run in parallel.

    - Task 1: agent `security-reviewer`
      > Read review story [SECURITY_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [SECURITY_ID].

    - Task 2: agent `architecture-reviewer`
      > Read review story [ARCH_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [ARCH_ID].

    - Task 3: agent `test-reviewer`
      > Read review story [TEST_ID]. Analyze these files: [MODIFIED_FILES] and their test counterparts. Write findings to story [TEST_ID].

    - Task 4: agent `docs-reviewer`
      > Read review story [DOCS_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [DOCS_ID].

11. Wait for all 4 tasks to complete (all statuses → "done").

---

## Phase 4 — Fix & Synthesize

12. Read all 4 review stories. Fix everything marked CRITICAL or MUST FIX immediately.

13. Use `update_story` on the original story to append `## Review Summary`:
    - CRITICAL/MUST FIX items and whether each was fixed
    - Remaining items (SHOULD FIX, NICE TO HAVE) as follow-up Tasks `- [ ]`
    - Links to all 4 review story IDs

14. Use `change_status` on the original story → "done".

15. Print final console summary:
    ```
    ✅ Story [ID/slug] complete
    📋 Reviews: #X (security) #X (arch) #X (testing) #X (docs)
    🔴 Critical issues fixed: N
    🟡 Remaining follow-ups: N
    ```

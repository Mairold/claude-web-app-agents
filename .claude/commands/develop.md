You are a development orchestrator. Implement a story fully using TDD, then validate with parallel review agents.

Story to develop: $ARGUMENTS

---

## Phase 1 — Read & Plan

1. Use `read_story` with "$ARGUMENTS" (works with both ID and slug).
2. Check if the story title contains "[FOLLOWUP]" — if yes, skip Phase 2 entirely and go straight to Phase 3.
3. Understand requirements fully. State assumptions clearly — do not ask, document them.
4. Use `update_story` to append under `## Details`:
   - Briefly: what will be built and key assumptions. No file lists.

---

## Phase 2a — Write Tests First

⚠️ DO NOT write any implementation code yet. Tests come first, always.

5. For every non-trivial class or function in your plan, write the unit tests first:
   - Test file structure and class names based on the plan
   - Cover: happy path, null/empty input, boundary values, error cases
   - Tests must follow Arrange-Act-Assert. One concept per test.
   - Tests will fail to compile — that is expected and correct at this stage.

6. Use `update_story` to append `## Test Plan` with the list of test files created.

---

## Phase 2b — Stub Implementations

⚠️ DO NOT implement real logic yet.

7. Create empty/stub implementations just enough to make the code compile:
   - Methods return `null`, `Optional.empty()`, or throw `UnsupportedOperationException`
   - All tests should now compile and **fail** (red). Verify this before moving on.

---

## Phase 2c — Implement

8. Implement the actual logic, following CLAUDE.md conventions, until all tests pass (green).
   - Work through one failing test at a time
   - Do not write code that isn't required by a failing test
   - Refactor after green — clean up without breaking tests (Boy Scout Rule)

9. Note the exact list of files created/modified — passed to review agents next.
   Update `## Tasks` checkboxes to `- [x]` as each task is completed.

---

## Phase 3 — Parallel Review

10. Spawn all 4 Tasks simultaneously — agents are fully independent and must run in parallel.
    Pass each agent the list of files from Phase 2 (or ask the user which files to review if this is a [FOLLOWUP] story).

    - Task 1: agent `security-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

    - Task 2: agent `architecture-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

    - Task 3: agent `test-reviewer`
      > Analyze these files: [MODIFIED_FILES] and their test counterparts. Return your findings as structured text.

    - Task 4: agent `docs-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

11. Wait for all 4 tasks to complete and collect their output.

---

## Phase 4 — Fix & Synthesize

12. Fix everything marked CRITICAL or MUST FIX immediately.

13. Use `update_story` ONCE on the original story to append `## Review Summary`
    with all 4 agent outputs as a compact summary:

    ```
    ## Review Summary
    No CRITICAL issues. / Fixed inline: [list what was fixed]

    | | Findings |
    |---|---|
    | Security | [one line: e.g. 3 MEDIUM — no rate limiting, CSRF disabled] |
    | Architecture | [one line: e.g. 2 MUST FIX — AuthController bloat, god class in McpService] |
    | Testing | [one line: e.g. missing controller tests, no integration tests] |
    | Docs | [one line: e.g. no README, endpoints undocumented] |
    ```

    Keep each row to one line. Omit rows with no findings.

14. If the story title contains "[FOLLOWUP]":
    - Append full detailed findings directly to this story as `## Security Findings`, `## Architecture Findings`, `## Testing Findings`, `## Docs Findings`
    - Do NOT create another follow-up story

    Otherwise, if SHOULD FIX, NICE TO HAVE, IMPORTANT, or MINOR items remain:
    - Use `create_story` for a single follow-up:
      - Title: `# Feature: [FOLLOWUP] <original story title> — <today's date>`
      - Tag: "followup"
      - `## Details`: brief summary
      - `## Tasks`: one `- [ ]` per remaining item prefixed with category (ARCH/TEST/SEC/DOCS)
      - Append full detailed findings as `## Security Findings`, `## Architecture Findings`, `## Testing Findings`, `## Docs Findings`

    If no remaining items, append full detailed findings directly to the original story.

15. Use `change_status` on the original story → "done".

16. Print final console summary:
    ```
    ✅ Story [ID/slug] complete
    🔴 Critical issues fixed: N
    🟡 Follow-up story created: #ID (N items) / none
    ```

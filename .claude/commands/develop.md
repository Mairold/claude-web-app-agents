You are a development orchestrator. Implement a story fully using TDD, then validate with parallel review agents.

Story to develop: $ARGUMENTS

---

## Phase 1 — Read & Plan

1. Use `read_story` with "$ARGUMENTS" (works with both ID and slug).
2. Understand requirements fully. State assumptions clearly — do not ask, document them.
3. **Check for acceptance criteria.** If the story has no `## Acceptance Criteria` section (or it's empty), use `update_story` to add one before starting implementation:
    ```
    ## Acceptance Criteria
    - [ ] [specific, testable criterion]
    - [ ] [mobile: works on touch devices if UI change]
    - [ ] [specific, testable criterion]
    ```
    Derive criteria from the story description and tasks. Each criterion must be concrete and verifiable.
4. If the story title does NOT contain "[FOLLOWUP]", use `update_story` to append under `## Details`:
    - Briefly: what will be built and key assumptions. No file lists. Do not repeat information that is already covered in the story.
5. If the story title contains "[FOLLOWUP]": the `## Tasks` checklist IS your plan — implement each task directly in Phase 2c (skip 2a/2b TDD scaffolding, just fix each item and verify tests pass).

---

## Phase 2a — Write Tests First

⚠️ DO NOT write any implementation code yet. Tests come first, always.

6. For every non-trivial class or function in your plan, write the unit tests first:
   - Test file structure and class names based on the plan
   - Cover: happy path, null/empty input, boundary values, error cases
   - Tests must follow Arrange-Act-Assert. One concept per test.
   - Tests will fail to compile — that is expected and correct at this stage.

7. Use `update_story` to append `## Test Plan` with the list of test files created.

---

## Phase 2b — Stub Implementations

⚠️ DO NOT implement real logic yet.

8. Create empty/stub implementations just enough to make the code compile:
   - Methods return `null`, `Optional.empty()`, or throw `UnsupportedOperationException`
   - All tests should now compile and **fail** (red). Verify this before moving on.

---

## Phase 2c — Implement

9. Implement the actual logic, following CLAUDE.md conventions, until all tests pass (green).
   - Work through one failing test at a time
   - Do not write code that isn't required by a failing test
   - Refactor after green — clean up without breaking tests (Boy Scout Rule)

10. Note the exact list of files created/modified — passed to review agents next.
   Update `## Tasks` checkboxes to `- [x]` as each task is completed.

---

## Phase 2d — E2E Tests (web projects with UI changes only)

Skip this phase if the story is backend-only (no UI changes) or the project has no browser frontend.

11. Spawn an Agent to run `/e2e-test $ARGUMENTS`. This agent handles everything: bootstrap (if needed), writing tests, running them, and updating the story.

---

## Phase 3 — Parallel Review

15. **Triage before review.** If ALL modified files are CSS-only, Tailwind class changes, or SVG icon components — skip the full review. Instead, append a short `## Review Summary` noting "Trivial/styling-only change — review skipped" and proceed to Phase 4 step 21.
    ⚠️ **This triage applies ONLY to reviews.** It does NOT apply to Phase 2d (E2E tests). If the story has UI changes, E2E tests must always be written regardless of how trivial the change appears.

16. Spawn all 4 Tasks simultaneously — agents are fully independent and must run in parallel.
    Pass each agent the list of files from Phase 2 (or ask the user which files to review if this is a [FOLLOWUP] story).

    - Task 1: agent `security-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

    - Task 2: agent `architecture-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

    - Task 3: agent `test-reviewer`
      > Analyze these files: [MODIFIED_FILES] and their test counterparts. Return your findings as structured text.

    - Task 4: agent `docs-reviewer`
      > Analyze these files: [MODIFIED_FILES]. Return your findings as structured text.

17. Wait for all 4 tasks to complete and collect their output.

---

## Phase 4 — Fix & Synthesize

18. Fix everything marked CRITICAL or MUST FIX immediately. Do NOT write review findings into the story — stories are for the user, not for internal review data.

19. If the story title contains "[FOLLOWUP]":
    - Do NOT create another follow-up story. Ever.

    Otherwise, if CRITICAL, MUST FIX, SHOULD FIX, or IMPORTANT items remain (exclude NICE TO HAVE, MINOR, and LOW):
    - Use `create_story` for a single follow-up:
      - Title: `# Feature: [FOLLOWUP] <original story title> — <today's date>`
      - Tag: "followup"
      - `## Tasks`: one `- [ ]` per remaining item prefixed with category (ARCH/TEST/SEC/DOCS)
      - Only include CRITICAL, MUST FIX, SHOULD FIX, and IMPORTANT items as tasks
      - Keep it minimal — task checklist only, no detailed findings sections

20. Use `change_status` on the original story → "done".

21. Print final console summary:
    ```
    ✅ Story [ID/slug] complete
    🔴 Critical issues fixed: N
    🟡 Follow-up story created: #ID (N items) / none

    📊 Tests: X/Y unit passed, X/Y E2E passed
    📋 E2E report: http://<machine-ip>:8082
    ```
    To get the report URL: run `npm run test:e2e:report` (or `npx http-server playwright-report -p 8082 -a 0.0.0.0 --cors -c-1`) and use the machine's network IP.

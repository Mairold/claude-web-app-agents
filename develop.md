You are a development orchestrator. Implement a story fully, then validate it with parallel review agents.

Story to develop: $ARGUMENTS

---

## Phase 1 — Read & Plan

1. Use `read_story` with "$ARGUMENTS" (works with both ID and slug).
2. Understand requirements fully. State assumptions clearly — do not ask, document them.
3. Use `update_story` to append under `## Details`:
   - Implementation plan: what you will build, files to create or modify, assumptions made

---

## Phase 2 — Implement

4. Implement the story fully — production-ready code, not scaffolding.
    - Create unit tests first for all non-trivial logic. Then make it compile with empty implementations. After that start implement
    - Follow conventions in CLAUDE.md
5. Use `update_story` to append a `## Implementation Notes` section with:
   - What was built and key decisions made
   - **Exact list of files created/modified** (passed to review agents)
   - Update `## Tasks` checkboxes to `- [x]` as each task is completed

---

## Phase 3 — Parallel Review

6. Use `create_story` for each review role with this title format:
   `# Feature: [REVIEW][role] <original story title> — <today's date>`
   Add tag "review-batch". Note each returned ID.
   Roles: security, architecture, testing, docs

7. Spawn 4 parallel Tasks using named agents. Pass each agent its story ID and the file paths from Phase 2.

   - Task 1: agent `security-reviewer`
     > Read review story [SECURITY_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [SECURITY_ID].

   - Task 2: agent `architecture-reviewer`
     > Read review story [ARCH_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [ARCH_ID].

   - Task 3: agent `test-reviewer`
     > Read review story [TEST_ID]. Analyze these files: [MODIFIED_FILES] and their test counterparts. Write findings to story [TEST_ID].

   - Task 4: agent `docs-reviewer`
     > Read review story [DOCS_ID]. Analyze these files: [MODIFIED_FILES]. Write findings to story [DOCS_ID].

8. Wait for all 4 tasks to complete (all statuses → "done").

---

## Phase 4 — Fix & Synthesize

9. Read all 4 review stories. Fix everything marked CRITICAL or MUST FIX in the codebase immediately.

10. Use `update_story` on the original story to append a `## Review Summary` section:
    - CRITICAL/MUST FIX items and whether each was fixed
    - Remaining items (SHOULD FIX, NICE TO HAVE) as follow-up Tasks `- [ ]`
    - Links to all 4 review story IDs

11. Use `change_status` on the original story → "done".

12. Print final console summary:
    ```
    ✅ Story [ID/slug] complete
    📋 Reviews: #X (security) #X (arch) #X (testing) #X (docs)
    🔴 Critical issues fixed: N
    🟡 Remaining follow-ups: N
    ```

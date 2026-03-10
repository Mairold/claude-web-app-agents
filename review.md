You are a review orchestrator. Run all review agents against already-implemented code.

Story to review: $ARGUMENTS

---

## Step 1 — Read Story

Use `read_story` with "$ARGUMENTS". Identify which files were modified/created (check "Implementation Notes" section if present, otherwise ask the user which paths to scan).

---

## Step 2 — Create Review Stories

Use `create_story` for each role. Title format: "[REVIEW][role] <original title> — <today's date>". Tag: "review-batch".

Roles: security, architecture, testing, docs. Note each returned ID.

---

## Step 3 — Spawn Parallel Agents

Spawn 4 parallel Tasks using these named agents:

- Task 1: agent `security-reviewer`
  > Read review story [SECURITY_ID]. Analyze these files: [PATHS]. Write findings to story [SECURITY_ID].

- Task 2: agent `architecture-reviewer`
  > Read review story [ARCH_ID]. Analyze these files: [PATHS]. Write findings to story [ARCH_ID].

- Task 3: agent `test-reviewer`
  > Read review story [TEST_ID]. Analyze these files: [PATHS] and their test counterparts. Write findings to story [TEST_ID].

- Task 4: agent `docs-reviewer`
  > Read review story [DOCS_ID]. Analyze these files: [PATHS]. Write findings to story [DOCS_ID].

Wait for all 4 to complete.

---

## Step 4 — Summarize

Read all 4 review stories. Use `update_story` on the original story to append:

```
## Review Findings Summary
- Security: #ID — N critical, N high, N medium
- Architecture: #ID — N must fix, N should fix
- Testing: #ID — N untested paths, N weak tests
- Docs: #ID — N blocking, N important
```

Print final summary to console:
```
✅ Review complete for story [ID/slug]
📋 Review stories: #X (security) #X (arch) #X (testing) #X (docs)
🔴 Items needing immediate attention: N
🟡 Follow-up items: N
```

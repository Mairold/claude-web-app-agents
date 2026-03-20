---
model: sonnet
---
Fix CRITICAL/MUST FIX findings and close the story. No follow-ups.

Story: $ARGUMENTS

---
1. Check that `/review` has been run for this story (look for ## Review Summary in the story via `read_story`, or check git log for review commits, or ask user to confirm). If missing, print:
   "⚠️ No review found for [slug] — run /review first or confirm skip."
   Wait for user response before continuing.

2. Fix all CRITICAL and MUST FIX findings from the review immediately.

3. If any code was changed in step 2, re-run ALL E2E tests:
   - Start test backend if needed: `docker compose -f docker-compose.test.yml up --build -d`
   - Run: `cd frontend && npx playwright test`
   - Fix any failures before continuing

4. SHOULD FIX / IMPORTANT / MEDIUM / LOW — log in review summary, do NOT create follow-up stories. If it's not worth fixing now, it's not worth tracking.

5. `change_status("$ARGUMENTS", "done")` (if MCP unavailable: print "[slug] done" and continue)

6. Print: `[slug] done`

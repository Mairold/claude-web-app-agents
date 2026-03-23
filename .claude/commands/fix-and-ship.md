---
model: sonnet
---
Fix CRITICAL/MUST FIX findings and close the story. No follow-ups.

Story: $ARGUMENTS

---
1. **Review check:** If args contain `--from-develop`, skip this check (review just ran in the pipeline).
   Otherwise, check that `/review` has been run for this story (look for ## Review Summary in the story via `read_story`, or check git log for review commits, or ask user to confirm). If missing, print:
   "⚠️ No review found for [slug] — run /review first or confirm skip."
   Wait for user response before continuing.

2. Fix all CRITICAL and MUST FIX / HIGH findings from the review immediately.

3. If any code was changed in step 2, re-run ALL E2E tests:
   - Start test backend if needed: `docker compose -f docker-compose.test.yml up --build -d`
   - Run: `cd frontend && npx playwright test`
   - Fix any failures before continuing

4. MEDIUM / SHOULD FIX / IMPORTANT — collect all into ONE follow-up story:
   - Title: `[FOLLOWUP] <slug> — review cleanup`
   - Body: checklist of all MEDIUM findings with file + line
   - Create via `create_story` (if MCP unavailable: print the story content)
   - Max ONE follow-up story per run — bundle all MEDIUM findings together
   LOW / Nice-to-have — ignore entirely.

5. `change_status("$ARGUMENTS", "done")` (if MCP unavailable: print "[slug] done" and continue)

6. Print: `[slug] done`

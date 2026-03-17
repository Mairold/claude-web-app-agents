---
model: sonnet
---
Fix CRITICAL/MUST FIX findings and close the story. No follow-ups.

Story: $ARGUMENTS

---

1. Fix all CRITICAL and MUST FIX findings from the review immediately.

2. If any code was changed in step 1, re-run ALL E2E tests:
   - Start test backend if needed: `docker compose -f docker-compose.test.yml up --build -d`
   - Run: `cd frontend && npx playwright test`
   - Fix any failures before continuing

3. SHOULD FIX / IMPORTANT / MEDIUM / LOW — log in review summary, do NOT create follow-up stories. If it's not worth fixing now, it's not worth tracking.

4. `change_status("$ARGUMENTS", "done")`

5. Print: `[slug] done`

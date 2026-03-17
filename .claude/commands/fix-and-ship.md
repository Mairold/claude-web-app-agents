---
model: sonnet
---
Fix review findings, close the story, create follow-up if needed.

Story: $ARGUMENTS

---

1. Fix all CRITICAL and MUST FIX findings from the review immediately.

2. If any code was changed in step 1, re-run ALL E2E tests:
   - Start test backend if needed: `docker compose -f docker-compose.test.yml up --build -d`
   - Run: `cd frontend && npx playwright test`
   - Fix any failures before continuing

3. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): do NOT create another follow-up. Ever.

4. **Regular stories** with remaining SHOULD FIX or IMPORTANT items:
   - `create_story` for a single follow-up:
     - Title: `[FOLLOWUP] <original title> — <today's date>`
     - Tag: "followup"
     - `## Tasks`: one `- [ ]` per item, prefixed with ARCH/TEST/SEC/DOCS/SVELTE/SPRING

5. `change_status("$ARGUMENTS", "done")`

6. Print: `[slug] done | Follow-up: #ID / none`

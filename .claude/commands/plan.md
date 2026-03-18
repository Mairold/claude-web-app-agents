---
model: sonnet
---
Read a story and add acceptance criteria and implementation plan.

Story: $ARGUMENTS

---

1. `read_story("$ARGUMENTS")` — understand requirements fully. State assumptions, do not ask.

2. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): the `## Tasks` checklist IS the plan — skip all steps below. Print: `Plan ready for [slug]`

3. **Check AC:** If no `## Acceptance Criteria` section (or empty), use `update_story` to add:
   - Concrete, testable criteria derived from description and tasks
   - Include mobile criterion if UI change
   - Include `- [ ]` checkbox format for each criterion

4. **Triage — decide scope of planning:**

   **Technical task** (migration, bug fix, refactor, config change, adding tests, dependency update):
   - Use `update_story` to append under `## Details`:
     - What will be done and key assumptions (1-2 sentences, no file lists)
     - Effort: [S/M/L] human → [S/M/L] with AI

   **User-facing feature** (new UI, new endpoint, user flow change, ambiguous scope):
   - First answer: (1) Is this the right problem to solve? (2) What's the actual user outcome? (3) What if we do nothing?
   - Use `update_story` to append under `## Details`:
     - CURRENT: [one line — what exists today]
     - THIS PLAN: [one line — what this story adds]
     - 12-MONTH: [one line — where this is heading]
     - Key assumptions (1-2 sentences, no file lists)
     - Effort: [S/M/L] human → [S/M/L] with AI
       (S=hours, M=day, L=days — AI typically drops one level)

5. Print: `Plan ready for [slug]`

---
model: sonnet
---
Read a story and add acceptance criteria and implementation plan.

Story: $ARGUMENTS

---

1. `read_story("$ARGUMENTS")` — understand requirements fully. State assumptions, do not ask.
2. **Check AC:** If no `## Acceptance Criteria` section (or empty), use `update_story` to add:
   - Concrete, testable criteria derived from description and tasks
   - Include mobile criterion if UI change
   - Include `- [ ]` checkbox format for each criterion
3. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): the `## Tasks` checklist IS the plan — skip AC and Details addition.
4. **Regular stories:** Use `update_story` to append under `## Details`:
   - What will be built and key assumptions (2-3 sentences max, no file lists)
   - Do not repeat information already in the story
5. Print: `Plan ready for [slug]`

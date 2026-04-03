---
model: sonnet
---
Read a story and add acceptance criteria and implementation plan.

Story: $ARGUMENTS

---

1. `read_story("$ARGUMENTS")` — understand requirements fully. State assumptions, do not ask.
   (If MCP unavailable: use $ARGUMENTS as description if it has spaces, else ask user to paste requirements.)
   If `$ARGUMENTS` starts with `--from-develop`, strip that prefix and treat the rest as the story slug.
   Store whether called from develop: `FROM_DEVELOP = $ARGUMENTS contains "--from-develop"`

2. **FOLLOWUP stories** (title contains "[FOLLOWUP]"): the `## Tasks` checklist IS the plan — skip all steps below. Print: `Plan ready for [slug]`

3. **Check AC:** If no `## Acceptance Criteria` section (or empty), use `update_story` to add:
   (If MCP unavailable: print the AC content instead.)
   - Concrete, testable criteria derived from description and tasks
   - Include mobile criterion if UI change
   - Include `- [ ]` checkbox format for each criterion

4. **Triage — decide scope of planning:**

   **Technical task** (migration, bug fix, refactor, config change, adding tests, dependency update):
   - Use `update_story` to append under `## Details` (if MCP unavailable: print instead):
     - What will be done and key assumptions (1-2 sentences, no file lists)
     - Effort: [S/M/L] human → [S/M/L] with AI

   **User-facing feature** (new UI, new endpoint, user flow change, ambiguous scope):
   - First answer: (1) Is this the right problem to solve? (2) What's the actual user outcome? (3) What if we do nothing?
   - Use `update_story` to append under `## Details` (if MCP unavailable: print instead):
     - CURRENT: [one line — what exists today]
     - THIS PLAN: [one line — what this story adds]
     - 12-MONTH: [one line — where this is heading]
     - Key assumptions (1-2 sentences, no file lists)
     - Effort: [S/M/L] human → [S/M/L] with AI
       (S=hours, M=day, L=days — AI typically drops one level)

5. **Technical approach (conditional):** Skip if the story already has a `## Technical Approach` section or equivalent technical detail, OR if the story is simple (single-file change, config tweak, copy change).

   Otherwise, explore the codebase (Glob, Grep, Read) to understand existing patterns, then use `update_story` to append under `## Technical Approach` (if MCP unavailable: print instead):
   - Which existing files/modules will be modified and why
   - New files/classes to create (with intended responsibility)
   - API changes (new or modified endpoints, request/response shape)
   - DB changes (new tables, columns, migrations)
   - Key design decision: if multiple approaches exist, state the chosen one and why
   - Reuse: name existing utilities, services, or patterns to build on — never duplicate

   **If called standalone (`/plan`):** Present the plan to the user and wait for approval before finishing. Do not proceed until the user confirms.
   **If called from `/develop`:** Write the plan and continue — do not wait for approval.

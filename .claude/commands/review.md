---
model: sonnet
---
Run review agents against implemented code. Conditionally includes tech-stack agents.

Story: $ARGUMENTS

---

## Step 1 — Determine scope
1. `read_story("$ARGUMENTS")` or use git diff to find modified files.
2. If no file list found, ask the user which paths to review.
3. **Triage:** If ALL files are CSS-only, Tailwind class changes, or SVG icon components — skip review entirely. Print: `Review skipped (trivial change)`.

## Step 2 — Select and spawn agents
Determine which agents to run based on modified file types:

**Always run (4 core agents):**
- `security-reviewer` (model: sonnet)
- `architecture-reviewer` (model: sonnet)
- `test-reviewer` (model: sonnet)
- `docs-reviewer` (model: haiku)

**Conditionally run:**
- If `.svelte`, `.js`, `.ts` files in `frontend/`: add `svelte-reviewer` (model: sonnet)
- If `.java` files in `backend/`: add `spring-reviewer` (model: sonnet)

Spawn ALL selected agents in parallel using the Agent tool. Pass each agent:
> Analyze these files: [MODIFIED_FILES]. Only review code written/modified in this story, not pre-existing issues. Return your findings as structured text.

## Step 3 — Synthesize
Collect all outputs. Print compact summary table (one line per agent, skip agents with no findings):
```
| Agent | Findings |
|-------|----------|
| Security | 1 HIGH: missing auth check on new endpoint |
| Spring | Clean |
```

Do NOT write review findings into the story — stories are for the user, not internal review data.
Only report CRITICAL and HIGH / MUST FIX findings for action. MEDIUM/LOW go into the summary but need no action.

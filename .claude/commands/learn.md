---
model: sonnet
---
Manually log a learning or promote an existing one to CLAUDE.md.

$ARGUMENTS: description of what was learned, OR a learning UUID to promote.

---

If $ARGUMENTS looks like a UUID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx):
  1. `list_learnings(include_promoted=true)` — find the learning by id
  2. Show it and ask: which file to add to? (CLAUDE.md / agent file / agent_docs/)
  3. Write the text to the chosen file
  4. `promote_learning(id)`
  5. Print: `Learning promoted to [file]`

Otherwise — log a new manual learning:
  1. Ask: category, severity
  2. `log_learning(phase="manual", project=<from CLAUDE.md>, finding=$ARGUMENTS, ...)`
  3. If severity is critical or high: also propose immediate addition to CLAUDE.md
  4. Print: `Learning logged`

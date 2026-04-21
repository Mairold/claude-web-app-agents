---
model: sonnet
---
Analyze accumulated metrics and learnings, propose improvements to agent files and CLAUDE.md.

$ARGUMENTS: optional project name. If empty, reads project name from CLAUDE.md.

---

## Step 1 — Show trends

Read project name from CLAUDE.md or use $ARGUMENTS.

Call `get_metrics_trend(project=<name>, days=30)` — last 30 days of weekly aggregates.

Print table:

```
| Week     | Runs | Avg duration | Avg findings | Tests 1st try | Success | Interventions |
|----------|------|--------------|--------------|---------------|---------|---------------|
| 2026-W15 | 12   | 18m          | 2.3          | 85%           | 92%     | 3             |
| 2026-W14 | 8    | 22m          | 3.1          | 78%           | 88%     | 5             |
| 2026-W13 | 10   | 25m          | 4.2          | 71%           | 80%     | 8             |
```

Compare the most recent week against the prior week and highlight improvements or regressions:

- `✅ Tests passing first try improving: 71% → 85%`
- `⚠️ Duration increasing: 18m → 22m`
- `✅ Review findings trending down: 4.2 → 2.3`

If MCP unavailable or no metrics yet: print `No metrics available` and continue to Step 2.

## Step 2 — Fetch learning patterns

- `list_learnings(project=<name>, min_occurrences=3)` — project-specific patterns
- `list_learnings(project=None, min_occurrences=5)` — cross-project patterns (accessible with current access key, not every project in the system)

## Step 3 — Analyze patterns

For each pattern:
- Skip if already present in CLAUDE.md, agent files, or `.claude/docs/`
- Skip if it's a one-off (not generalizable to a rule)
- Propose exact text: which file, which section, what wording

## Step 4 — Print report

```
## Retro — [project] — [date]

### Patterns worth promoting ([N] total)

[category] — seen [N] times, projects: [list]
Finding: [description]
→ Add to [file] under [section]:
  [exact proposed text]

Promote this? (y/n)
```

## Step 5 — Apply confirmations

For each pattern the user confirms with `y`:
- Write the proposed text to the appropriate file
- Call `promote_learning(id, scope="project")` or `scope="global"` for cross-project

## Step 6 — Done

Print: `Retro done — [N] patterns promoted`

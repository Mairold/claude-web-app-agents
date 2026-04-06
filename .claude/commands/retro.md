---
model: sonnet
---
Analyze accumulated learnings and propose improvements to agent files and CLAUDE.md.

$ARGUMENTS: optional project name. If empty, reads project name from CLAUDE.md.

---

1. Read project name from CLAUDE.md or use $ARGUMENTS.

2. Fetch patterns:
   - `list_learnings(project=<name>, min_occurrences=3)` — project-specific
   - `list_learnings(project=None, min_occurrences=5)` — all projects accessible
     with current access key (not all projects in the system)

3. For each pattern:
   - Skip if already present in CLAUDE.md, agent files, or agent_docs/
   - Skip if it's a one-off (not generalizable to a rule)
   - Propose exact text: which file, which section, what wording

4. Print report:

   ```
   ## Retro — [project] — [date]

   ### Patterns worth promoting ([N] total)

   [category] — seen [N] times, projects: [list]
   Finding: [description]
   → Add to [file] under [section]:
     [exact proposed text]

   Promote this? (y/n)
   ```

5. For each pattern the user confirms with "y":
   - Write the proposed text to the appropriate file
   - Call `promote_learning(id, scope="project")` or `scope="global"` for cross-project

6. Print: `Retro done — [N] patterns promoted`
